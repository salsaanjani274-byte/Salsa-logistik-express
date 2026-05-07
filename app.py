from flask import Flask, render_template, redirect, url_for, request, session, flash, jsonify
from flask_mysqldb import MySQL
from functools import wraps
import random
import string
import os
import requests
import uuid
from datetime import datetime
from werkzeug.utils import secure_filename

app = Flask(__name__)
app.secret_key = 'logistik_secret_key_SALSA-ANJANI'

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''
app.config['MYSQL_DB'] = 'db_logistik_xendit'
app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

mysql = MySQL(app)

XENDIT_SECRET_KEY      = os.environ.get('XENDIT_SECRET_KEY', '')
XENDIT_WEBHOOK_TOKEN   = os.environ.get('XENDIT_WEBHOOK_TOKEN', '')
XENDIT_API_BASE        = 'https://api.xendit.co'

_DEFAULT_BASE = 'http://localhost:5000'
APP_BASE_URL            = os.environ.get('APP_BASE_URL', _DEFAULT_BASE).rstrip('/')
XENDIT_CALLBACK_URL     = APP_BASE_URL + '/webhook/xendit'
XENDIT_SUCCESS_REDIRECT = APP_BASE_URL + '/payment/success'
XENDIT_FAILURE_REDIRECT = APP_BASE_URL + '/payment/failure'

UPLOAD_FOLDER     = os.path.join(os.path.dirname(__file__), 'static', 'uploads', 'pod')
ALLOWED_EXTENSIONS = {'jpg', 'jpeg', 'png', 'webp'}
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['MAX_CONTENT_LENGTH'] = 10 * 1024 * 1024  # 10MB max

os.makedirs(UPLOAD_FOLDER, exist_ok=True)


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def create_xendit_invoice(paket_id, no_resi, jumlah, nama_pengirim, email='noreply@logistik.com', deskripsi=None):
    """Buat invoice Xendit dan kembalikan invoice_id + payment_url."""
    external_id = f"LGS-{no_resi}-{paket_id}-{uuid.uuid4().hex[:8].upper()}"
    payload = {
        "external_id": external_id,
        "amount": int(jumlah),
        "description": deskripsi or f"Pembayaran pengiriman paket {no_resi}",
        "invoice_duration": 86400,  # 24 jam
        "customer": {"given_names": nama_pengirim, "email": email},
        "success_redirect_url": XENDIT_SUCCESS_REDIRECT + f"?resi={no_resi}",
        "failure_redirect_url": XENDIT_FAILURE_REDIRECT + f"?resi={no_resi}",
        "currency": "IDR",
        "items": [{"name": f"Ongkir {no_resi}", "quantity": 1, "price": int(jumlah)}],
        "payment_methods": ["OVO","DANA","LINKAJA","SHOPEEPAY","BCA","BNI","BRI","MANDIRI","QRIS","CREDIT_CARD"]
    }
    resp = requests.post(
        f"{XENDIT_API_BASE}/v2/invoices",
        auth=(XENDIT_SECRET_KEY, ''),
        json=payload,
        timeout=15
    )
    resp.raise_for_status()
    data = resp.json()
    return {
        'invoice_id':  data['id'],
        'invoice_url': data['invoice_url'],
        'external_id': external_id,
        'status':      data['status']
    }


def verify_xendit_webhook(token_header):
    """Verifikasi webhook callback dari Xendit."""
    return token_header == XENDIT_WEBHOOK_TOKEN


def generate_resi(kode_cabang='LGS'):
    timestamp   = datetime.now().strftime('%y%m%d%H%M')
    random_part = ''.join(random.choices(string.digits, k=4))
    return f"LGS{kode_cabang}{timestamp}{random_part}"

def hitung_berat_volumetrik(p, l, t, jalur='darat'):
    if not (p and l and t):
        return 0.0
    divisor = 5000 if jalur == 'darat' else 4000
    return round((p * l * t) / divisor, 2)


def hitung_biaya(berat_kg, harga_per_kg, nilai_barang=0):
    biaya_kirim    = berat_kg * harga_per_kg
    biaya_asuransi = nilai_barang * 0.002 if nilai_barang > 0 else 0
    return round(biaya_kirim, 2), round(biaya_asuransi, 2), round(biaya_kirim + biaya_asuransi, 2)


def cek_keterlambatan(paket):
    from datetime import timedelta
    status_selesai = ('delivered', 'returned', 'failed_delivery', 'on_hold')
    if paket['status'] in status_selesai:
        return {'terlambat': False, 'hari_estimasi': 0, 'hari_berjalan': 0,
                'selisih_hari': 0, 'estimasi_tiba': None, 'label': 'Selesai', 'warna': 'success'}
    created       = paket.get('created_at')
    hari_estimasi = int(paket.get('estimasi_hari', 0) or 0)
    if not created or hari_estimasi == 0:
        return {'terlambat': False, 'hari_estimasi': 0, 'hari_berjalan': 0,
                'selisih_hari': 0, 'estimasi_tiba': None, 'label': '-', 'warna': 'secondary'}
    estimasi_tiba = created.date() + timedelta(days=hari_estimasi)
    hari_berjalan = (datetime.now().date() - created.date()).days
    selisih       = hari_berjalan - hari_estimasi
    if selisih > 0:
        return {'terlambat': True, 'hari_estimasi': hari_estimasi, 'hari_berjalan': hari_berjalan,
                'selisih_hari': selisih, 'estimasi_tiba': estimasi_tiba,
                'label': f'Terlambat {selisih} hari', 'warna': 'danger'}
    elif selisih == 0:
        return {'terlambat': False, 'hari_estimasi': hari_estimasi, 'hari_berjalan': hari_berjalan,
                'selisih_hari': 0, 'estimasi_tiba': estimasi_tiba,
                'label': 'Jatuh tempo hari ini', 'warna': 'warning'}
    else:
        sisa = abs(selisih)
        return {'terlambat': False, 'hari_estimasi': hari_estimasi, 'hari_berjalan': hari_berjalan,
                'selisih_hari': selisih, 'estimasi_tiba': estimasi_tiba,
                'label': f'Sisa {sisa} hari', 'warna': 'info' if sisa <= 1 else 'success'}


app.jinja_env.globals['cek_keterlambatan'] = cek_keterlambatan


def add_tracking(paket_id, status, keterangan, lokasi, user_id, latitude=None, longitude=None):
    cur = mysql.connection.cursor()
    cur.execute("""INSERT INTO riwayat_status (paket_id, status, keterangan, lokasi, user_id, latitude, longitude)
                   VALUES (%s, %s, %s, %s, %s, %s, %s)""",
                (paket_id, status, keterangan, lokasi, user_id, latitude, longitude))
    mysql.connection.commit()
    cur.close()



STATUS_LABEL = {
    'created':              ('Paket Dibuat',                  'primary'),
    'sorting_origin':       ('Sortir di Cabang Asal',         'warning'),
    'in_transit_gateway':   ('Dikirim ke Gateway Kota Asal',  'info'),
    'gateway_origin':       ('Proses di Gateway Asal',        'info'),
    'on_transit':           ('Dalam Perjalanan Antar Kota',   'warning'),
    'arrived_gateway_dest': ('Tiba di Gateway Kota Tujuan',   'success'),
    'out_for_delivery':     ('Sedang Diantar Kurir',          'primary'),
    'delivered':            ('Terkirim (POD)',                 'success'),
    'failed_delivery':      ('Gagal Antar',                   'danger'),
    'on_hold':              ('Ditahan (Hold)',                 'warning'),
    'return_process':       ('Proses Retur',                  'warning'),
    'returned':             ('Dikembalikan',                  'danger'),
    'problem':              ('Bermasalah',                    'danger'),
}
app.jinja_env.globals['STATUS_LABEL'] = STATUS_LABEL

STATUS_ORDER = [
    'created', 'sorting_origin', 'in_transit_gateway',
    'gateway_origin', 'on_transit',
    'arrived_gateway_dest', 'out_for_delivery', 'delivered',
]

def get_allowed_status_for_admin(cabang_id, paket):
    cabang_id = int(cabang_id) if cabang_id else None

    cur = mysql.connection.cursor()
    cur.execute("SELECT tipe FROM cabang WHERE id=%s", (cabang_id,))
    row = cur.fetchone()
    cur.close()
    tipe = row['tipe'] if row else 'cabang'

    darurat = ['problem', 'returned', 'return_process']

    # Status paket saat ini — penting untuk validasi transisi
    status_sekarang = paket.get('status', '')

    # Ambil field langsung dari kolom tabel paket (bukan alias JOIN)
    # cabang_asal_id = cabang pengirim, gateway_id = gateway asal, gateway_tujuan_id = gateway tujuan
    try:
        paket_asal = int(paket['cabang_asal_id']) if paket.get('cabang_asal_id') else None
    except (TypeError, ValueError):
        paket_asal = None

    try:
        gateway_asal = int(paket['gateway_id']) if paket.get('gateway_id') else None
    except (TypeError, ValueError):
        gateway_asal = None

    try:
        gateway_tujuan = int(paket['gateway_tujuan_id']) if paket.get('gateway_tujuan_id') else None
    except (TypeError, ValueError):
        gateway_tujuan = None

    # ── Cabang Asal ──────────────────────────────────────────────────────────
    # Hanya berlaku jika tipe cabang (bukan gateway/pusat), atau memang asal paket
    # Paket harus dalam status awal (created, sorting_origin) untuk bisa disortir/dikirim
    if tipe == 'cabang' and paket_asal == cabang_id:
        if status_sekarang in ('created', 'sorting_origin'):
            return ['sorting_origin', 'in_transit_gateway'] + darurat
        return darurat

    # ── Gateway / Pusat ──────────────────────────────────────────────────────
    if tipe in ('gateway', 'pusat'):
        # Paket tanpa gateway (tidak melewati gateway sama sekali) → tidak berwenang
        if gateway_asal is None and gateway_tujuan is None:
            return darurat

        # Berperan sebagai Gateway Asal
        # Paket harus sudah tiba di gateway asal (in_transit_gateway → gateway_origin/on_transit)
        if gateway_asal == cabang_id:
            if status_sekarang == 'in_transit_gateway':
                allowed = ['gateway_origin', 'on_transit']
                if gateway_tujuan is not None and gateway_asal == gateway_tujuan:
                    # Paket lokal: langsung bisa kirim ke kurir setelah tiba di gateway
                    allowed += ['arrived_gateway_dest', 'out_for_delivery']
                return allowed + darurat
            if status_sekarang == 'gateway_origin':
                allowed = ['on_transit']
                if gateway_tujuan is not None and gateway_asal == gateway_tujuan:
                    allowed += ['arrived_gateway_dest', 'out_for_delivery']
                return allowed + darurat

        # Berperan sebagai Gateway Tujuan (antar kota)
        # Paket harus sudah tiba di gateway tujuan
        if gateway_tujuan == cabang_id:
            if status_sekarang == 'arrived_gateway_dest':
                return ['out_for_delivery'] + darurat
            # Jika paket baru arrived (on_transit tapi belum di-konfirmasi arrived)
            # Gateway tujuan bisa set arrived_gateway_dest terlebih dahulu
            if status_sekarang == 'on_transit':
                return ['arrived_gateway_dest'] + darurat

    return darurat


def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'user_id' not in session:
            flash('Silakan login terlebih dahulu.', 'warning')
            return redirect(url_for('login'))
        return f(*args, **kwargs)
    return decorated


def role_required(*roles):
    def decorator(f):
        @wraps(f)
        def decorated(*args, **kwargs):
            if 'user_id' not in session:
                return redirect(url_for('login'))
            if session.get('role') not in roles:
                flash('Akses ditolak.', 'danger')
                return redirect(url_for('dashboard_redirect'))
            return f(*args, **kwargs)
        return decorated
    return decorator

@app.route('/')
def index():
    return redirect(url_for('tracking'))


@app.route('/tracking', methods=['GET', 'POST'])
def tracking():
    paket, riwayat, no_resi = None, [], ''
    if request.method == 'POST':
        no_resi = request.form.get('no_resi', '').strip()
        cur = mysql.connection.cursor()
        cur.execute("""
            SELECT p.*, u.nama AS pengirim, l.nama AS layanan_nama, l.kode AS layanan_kode,
                   ca.nama_cabang AS cabang_asal_nama,
                   ga.nama_cabang AS gateway_asal_nama,
                   gt.nama_cabang AS gateway_tujuan_nama
            FROM paket p
            JOIN users u   ON p.pengirim_id      = u.id
            JOIN layanan l ON p.layanan_id        = l.id
            JOIN cabang ca ON p.cabang_asal_id    = ca.id
            LEFT JOIN cabang ga ON p.gateway_id         = ga.id
            LEFT JOIN cabang gt ON p.gateway_tujuan_id  = gt.id
            WHERE p.no_resi = %s
        """, (no_resi,))
        paket = cur.fetchone()
        if paket:
            cur.execute("""SELECT r.*, u.nama AS petugas FROM riwayat_status r
                JOIN users u ON r.user_id=u.id WHERE r.paket_id=%s ORDER BY r.created_at ASC""",
                (paket['id'],))
            riwayat = cur.fetchall()
        cur.close()
    return render_template('tracking.html', paket=paket, riwayat=riwayat,
                           no_resi=no_resi, STATUS_ORDER=STATUS_ORDER)



@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'user_id' in session:
        return redirect(url_for('dashboard_redirect'))
    if request.method == 'POST':
        username = request.form.get('username', '').strip()
        password = request.form.get('password', '')
        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM users WHERE username=%s AND status='aktif'", (username,))
        user = cur.fetchone()
        cur.close()
        if user and password == user['password']:
            if user['role'] in ('pelanggan', 'pengirim_tamu'):
                flash('Akun ini tidak memiliki akses sistem internal.', 'danger')
                return render_template('auth/login.html')
            session.update({'user_id': user['id'], 'nama': user['nama'],
                            'role': user['role'], 'cabang_id': user['cabang_id']})
            flash(f'Selamat datang, {user["nama"]}!', 'success')
            return redirect(url_for('dashboard_redirect'))
        flash('Username atau password salah.', 'danger')
    return render_template('auth/login.html')


@app.route('/logout')
def logout():
    session.clear()
    flash('Anda telah logout.', 'info')
    return redirect(url_for('login'))


@app.route('/dashboard')
@login_required
def dashboard_redirect():
    role = session.get('role')
    if role == 'pengelola':      return redirect(url_for('pengelola_dashboard'))
    if role == 'admin_cabang':   return redirect(url_for('admin_dashboard'))
    if role == 'kurir':          return redirect(url_for('kurir_dashboard'))
    if role == 'driver':         return redirect(url_for('driver_dashboard'))
    flash('Role tidak dikenal.', 'danger')
    return redirect(url_for('login'))


@app.route('/pengelola')
@role_required('pengelola')
def pengelola_dashboard():
    cur = mysql.connection.cursor()
    cur.execute("SELECT COUNT(*) as total FROM paket")
    total_paket = cur.fetchone()['total']
    cur.execute("SELECT COUNT(*) as total FROM paket WHERE status='delivered'")
    delivered = cur.fetchone()['total']
    cur.execute("SELECT COUNT(*) as total FROM paket WHERE status NOT IN ('delivered','returned','failed_delivery')")
    on_process = cur.fetchone()['total']
    cur.execute("SELECT COALESCE(SUM(total_biaya),0) as total FROM paket")
    total_rev = cur.fetchone()['total']
    cur.execute("SELECT COALESCE(SUM(total_biaya),0) as total FROM paket WHERE MONTH(created_at)=MONTH(NOW()) AND YEAR(created_at)=YEAR(NOW())")
    rev_bulan = cur.fetchone()['total']
    cur.execute("SELECT COUNT(*) as total FROM users WHERE role='kurir'")
    total_kurir = cur.fetchone()['total']
    cur.execute("""SELECT p.*, u.nama AS pengirim_nama, l.kode AS layanan_kode, l.estimasi_hari
        FROM paket p JOIN users u ON p.pengirim_id=u.id JOIN layanan l ON p.layanan_id=l.id
        ORDER BY p.created_at DESC LIMIT 10""")
    pakets = cur.fetchall()
    cur.execute("""SELECT COUNT(*) as total FROM paket p JOIN layanan l ON p.layanan_id=l.id
        WHERE p.status NOT IN ('delivered','returned','failed_delivery')
          AND DATEDIFF(NOW(), p.created_at) > l.estimasi_hari""")
    total_terlambat = cur.fetchone()['total']
    cur.execute("SELECT * FROM cabang ORDER BY tipe DESC")
    cabangs = cur.fetchall()
    cur.execute("SELECT u.*, c.nama_cabang FROM users u LEFT JOIN cabang c ON u.cabang_id=c.id ORDER BY u.created_at ASC")
    users = cur.fetchall()
    cur.execute("SELECT COALESCE(SUM(jumlah),0) as total FROM pembayaran WHERE status='lunas' AND MONTH(created_at)=MONTH(NOW()) AND YEAR(created_at)=YEAR(NOW())")
    total_payment_bulan = cur.fetchone()['total']
    cur.execute("SELECT COUNT(*) as total FROM pembayaran WHERE status='pending'")
    payment_pending = cur.fetchone()['total']
    cur.close()
    return render_template('pengelola/dashboard.html',
        total_paket=total_paket, delivered=delivered, on_process=on_process,
        total_rev=total_rev, rev_bulan=rev_bulan, total_kurir=total_kurir,
        total_terlambat=total_terlambat, total_payment_bulan=total_payment_bulan,
        payment_pending=payment_pending, pakets=pakets, cabangs=cabangs, users=users)


@app.route('/pengelola/cabang/tambah', methods=['GET', 'POST'])
@role_required('pengelola')
def pengelola_tambah_cabang():
    cur = mysql.connection.cursor()
    if request.method == 'POST':
        try:
            cur.execute("""INSERT INTO cabang (kode_cabang, nama_cabang, kota, provinsi, alamat, no_telp, tipe, status)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s)""",
                (request.form['kode_cabang'], request.form['nama_cabang'], request.form['kota'],
                 request.form['provinsi'], request.form['alamat'], request.form['no_telp'],
                 request.form['tipe'], request.form['status']))
            mysql.connection.commit()
            flash('Cabang berhasil ditambahkan.', 'success')
            return redirect(url_for('pengelola_dashboard'))
        except Exception as e:
            mysql.connection.rollback()
            flash(f'Gagal: {str(e)}', 'danger')
    cur.close()
    return render_template('pengelola/tambah_cabang.html')


@app.route('/pengelola/users/tambah', methods=['GET', 'POST'])
@role_required('pengelola')
def pengelola_tambah_user():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM cabang WHERE status='aktif'")
    cabangs = cur.fetchall()
    if request.method == 'POST':
        cabang_id = request.form.get('cabang_id') or None
        username  = request.form.get('username', '').strip()
        # Validasi username: hanya huruf, angka, titik, underscore
        import re
        if not re.match(r'^[a-zA-Z0-9._]{3,50}$', username):
            flash('Username tidak valid. Gunakan huruf, angka, titik, atau underscore (min 3 karakter).', 'danger')
            cur.close()
            return render_template('pengelola/tambah_user.html', cabangs=cabangs)
        # Cek username sudah dipakai
        cur.execute("SELECT id FROM users WHERE username=%s", (username,))
        if cur.fetchone():
            flash('Username sudah digunakan, pilih username lain.', 'danger')
            cur.close()
            return render_template('pengelola/tambah_user.html', cabangs=cabangs)
        cur.execute("INSERT INTO users (nama, username, email, password, role, no_hp, cabang_id) VALUES (%s,%s,%s,%s,%s,%s,%s)",
                    (request.form['nama'], username, request.form.get('email', ''), hash_password(request.form['password']),
                     request.form['role'], request.form['no_hp'], cabang_id))
        mysql.connection.commit()
        flash('User berhasil ditambahkan.', 'success')
        cur.close()
        return redirect(url_for('pengelola_dashboard'))
    cur.close()
    return render_template('pengelola/tambah_user.html', cabangs=cabangs)


@app.route('/pengelola/users/hapus/<int:uid>')
@role_required('pengelola')
def pengelola_hapus_user(uid):
    cur = mysql.connection.cursor()
    cur.execute("UPDATE users SET status='nonaktif' WHERE id=%s", (uid,))
    mysql.connection.commit()
    cur.close()
    flash('User dinonaktifkan.', 'warning')
    return redirect(url_for('pengelola_dashboard'))


@app.route('/pengelola/users/aktif/<int:uid>')
@role_required('pengelola')
def pengelola_aktif_user(uid):
    cur = mysql.connection.cursor()
    cur.execute("UPDATE users SET status='aktif' WHERE id=%s", (uid,))
    mysql.connection.commit()
    cur.close()
    flash('User diaktifkan kembali.', 'success')
    return redirect(url_for('pengelola_dashboard'))


@app.route('/pengelola/laporan')
@role_required('pengelola')
def pengelola_laporan():
    cur = mysql.connection.cursor()

    cabang_filter = request.args.get('cabang_id', '')
    tgl_dari      = request.args.get('tgl_dari', '')
    tgl_sampai    = request.args.get('tgl_sampai', '')

    where_parts = []
    params      = []

    if cabang_filter:
        where_parts.append('p.cabang_asal_id = %s')
        params.append(cabang_filter)
    if tgl_dari:
        where_parts.append('DATE(p.created_at) >= %s')
        params.append(tgl_dari)
    if tgl_sampai:
        where_parts.append('DATE(p.created_at) <= %s')
        params.append(tgl_sampai)

    where_sql = ('WHERE ' + ' AND '.join(where_parts)) if where_parts else ''

    cur.execute(f"""SELECT p.*, u.nama AS pengirim, l.nama AS layanan, ca.nama_cabang AS cabang_asal,
               py.status AS payment_status, py.metode AS payment_metode, py.jumlah AS payment_jumlah
        FROM paket p JOIN users u ON p.pengirim_id=u.id JOIN layanan l ON p.layanan_id=l.id
        JOIN cabang ca ON p.cabang_asal_id=ca.id LEFT JOIN pembayaran py ON py.paket_id=p.id
        {where_sql}
        ORDER BY p.created_at DESC""", params)
    pakets = cur.fetchall()

    cur.execute("SELECT status, COUNT(*) as total FROM paket GROUP BY status")
    status_count = cur.fetchall()

    cur.execute("""SELECT DATE_FORMAT(created_at,'%Y-%m') AS periode, COUNT(*) AS jumlah_transaksi,
               COALESCE(SUM(jumlah),0) AS total_pendapatan,
               COALESCE(SUM(CASE WHEN status='lunas' THEN jumlah ELSE 0 END),0) AS sudah_dibayar,
               COALESCE(SUM(CASE WHEN status='pending' THEN jumlah ELSE 0 END),0) AS belum_dibayar
        FROM pembayaran GROUP BY DATE_FORMAT(created_at,'%Y-%m') ORDER BY periode DESC LIMIT 12""")
    laporan_bulan = cur.fetchall()

    cur.execute("""SELECT COALESCE(SUM(jumlah),0) AS total_omset,
               COALESCE(SUM(CASE WHEN status='lunas' THEN jumlah ELSE 0 END),0) AS total_lunas,
               COALESCE(SUM(CASE WHEN status='pending' THEN jumlah ELSE 0 END),0) AS total_pending,
               COUNT(*) AS total_transaksi FROM pembayaran""")
    rekap = cur.fetchone()

    cur.execute("""SELECT cb.nama_cabang, cb.kota, COUNT(p.id) AS total_paket,
               COALESCE(SUM(p.total_biaya),0) AS total_pendapatan
        FROM cabang cb LEFT JOIN paket p ON p.cabang_asal_id=cb.id
        GROUP BY cb.id ORDER BY total_pendapatan DESC""")
    per_cabang = cur.fetchall()

    # Semua cabang untuk dropdown filter
    cur.execute("SELECT id, nama_cabang, tipe FROM cabang ORDER BY tipe DESC, nama_cabang ASC")
    all_cabangs = cur.fetchall()

    cur.close()
    return render_template('pengelola/laporan.html',
        pakets=pakets, status_count=status_count, laporan_bulan=laporan_bulan,
        rekap=rekap, per_cabang=per_cabang, all_cabangs=all_cabangs,
        cabang_filter=cabang_filter, tgl_dari=tgl_dari, tgl_sampai=tgl_sampai)


@app.route('/pengelola/keuangan')
@role_required('pengelola')
def pengelola_keuangan():
    cur = mysql.connection.cursor()

    cabang_filter  = request.args.get('cabang_id', '')
    tgl_dari       = request.args.get('tgl_dari', '')
    tgl_sampai     = request.args.get('tgl_sampai', '')

    where_parts = []
    params      = []

    if cabang_filter:
        where_parts.append('p.cabang_asal_id = %s')
        params.append(cabang_filter)
    if tgl_dari:
        where_parts.append('DATE(py.created_at) >= %s')
        params.append(tgl_dari)
    if tgl_sampai:
        where_parts.append('DATE(py.created_at) <= %s')
        params.append(tgl_sampai)

    where_sql = ('WHERE ' + ' AND '.join(where_parts)) if where_parts else ''

    cur.execute(f"""SELECT py.*, p.no_resi, p.kota_asal, p.kota_tujuan, p.total_biaya,
               u.nama AS pengirim_nama, l.kode AS layanan_kode,
               cb.nama_cabang AS cabang_nama, pu.nama AS dicatat_oleh_nama
        FROM pembayaran py JOIN paket p ON py.paket_id=p.id JOIN users u ON p.pengirim_id=u.id
        JOIN layanan l ON p.layanan_id=l.id JOIN cabang cb ON p.cabang_asal_id=cb.id
        LEFT JOIN users pu ON py.dicatat_oleh=pu.id
        {where_sql}
        ORDER BY py.created_at DESC""", params)
    payments = cur.fetchall()

    cur.execute(f"""SELECT COALESCE(SUM(py.jumlah),0) AS total_omset,
               COALESCE(SUM(CASE WHEN py.status='lunas' THEN py.jumlah ELSE 0 END),0) AS total_lunas,
               COALESCE(SUM(CASE WHEN py.status='pending' THEN py.jumlah ELSE 0 END),0) AS total_pending,
               COUNT(*) AS total_transaksi,
               COALESCE(SUM(CASE WHEN MONTH(py.created_at)=MONTH(NOW()) AND py.status='lunas' THEN py.jumlah ELSE 0 END),0) AS bulan_ini
        FROM pembayaran py JOIN paket p ON py.paket_id=p.id
        {where_sql}""", params)
    rekap = cur.fetchone()

    cur.execute("""SELECT DATE_FORMAT(created_at,'%Y-%m') AS bln,
               SUM(CASE WHEN status='lunas' THEN jumlah ELSE 0 END) AS lunas,
               SUM(CASE WHEN status='pending' THEN jumlah ELSE 0 END) AS pending
        FROM pembayaran GROUP BY DATE_FORMAT(created_at,'%Y-%m') ORDER BY bln DESC LIMIT 6""")
    tren = list(reversed(cur.fetchall()))

    cur.execute("""SELECT cb.nama_cabang, COUNT(py.id) AS total_transaksi,
               COALESCE(SUM(py.jumlah),0) AS total_pendapatan,
               COALESCE(SUM(CASE WHEN py.status='lunas' THEN py.jumlah ELSE 0 END),0) AS sudah_lunas
        FROM cabang cb LEFT JOIN paket p ON p.cabang_asal_id=cb.id
        LEFT JOIN pembayaran py ON py.paket_id=p.id GROUP BY cb.id ORDER BY total_pendapatan DESC""")
    per_cabang = cur.fetchall()

    # Semua cabang untuk dropdown filter
    cur.execute("SELECT id, nama_cabang, tipe FROM cabang ORDER BY tipe DESC, nama_cabang ASC")
    all_cabangs = cur.fetchall()

    cur.close()
    return render_template('pengelola/keuangan.html',
        payments=payments, rekap=rekap, tren=tren, per_cabang=per_cabang,
        all_cabangs=all_cabangs,
        cabang_filter=cabang_filter, tgl_dari=tgl_dari, tgl_sampai=tgl_sampai)


@app.route('/pengelola/keterlambatan')
@role_required('pengelola')
def pengelola_keterlambatan():
    cur = mysql.connection.cursor()
    cur.execute("""SELECT p.*, u.nama AS pengirim, l.nama AS layanan_nama,
               l.kode AS layanan_kode, l.estimasi_hari, cb.nama_cabang AS cabang_asal,
               DATEDIFF(NOW(), p.created_at) AS hari_berjalan,
               (DATEDIFF(NOW(), p.created_at) - l.estimasi_hari) AS selisih_hari
        FROM paket p JOIN users u ON p.pengirim_id=u.id JOIN layanan l ON p.layanan_id=l.id
        JOIN cabang cb ON p.cabang_asal_id=cb.id
        WHERE p.status NOT IN ('delivered','returned','failed_delivery')
          AND DATEDIFF(NOW(), p.created_at) > l.estimasi_hari ORDER BY selisih_hari DESC""")
    pakets_terlambat = cur.fetchall()
    cur.close()
    return render_template('pengelola/keterlambatan.html',
        pakets_terlambat=pakets_terlambat)

@app.route('/api/laporan/chart')
@role_required('pengelola')
def api_laporan_chart():
    cur = mysql.connection.cursor()
    cur.execute("""SELECT DATE_FORMAT(created_at,'%Y-%m') AS bln, SUM(jumlah) AS total
        FROM pembayaran WHERE status='lunas' GROUP BY bln ORDER BY bln DESC LIMIT 6""")
    rows = cur.fetchall()
    cur.close()
    return jsonify(list(reversed(rows)))


@app.route('/admin')
@role_required('admin_cabang')
def admin_dashboard():
    cabang_id = session['cabang_id']
    cur = mysql.connection.cursor()

    cur.execute("SELECT * FROM cabang WHERE id=%s", (cabang_id,))
    cabang = cur.fetchone()

    cur.execute("SELECT COUNT(*) as t FROM paket WHERE cabang_asal_id=%s", (cabang_id,))
    total = cur.fetchone()['t']
    cur.execute("SELECT COUNT(*) as t FROM paket WHERE cabang_asal_id=%s AND status='delivered'", (cabang_id,))
    delivered = cur.fetchone()['t']
    cur.execute("SELECT COUNT(*) as t FROM paket WHERE cabang_asal_id=%s AND status='out_for_delivery'", (cabang_id,))
    on_delivery = cur.fetchone()['t']
    cur.execute("""SELECT COALESCE(SUM(py.jumlah),0) as total FROM pembayaran py
        JOIN paket p ON py.paket_id=p.id WHERE p.cabang_asal_id=%s AND py.status='lunas'""", (cabang_id,))
    pendapatan_cabang = cur.fetchone()['total']

    cur.execute("""
        SELECT p.*, u.nama AS pengirim_nama, l.kode AS layanan_kode, l.estimasi_hari,
               k.nama AS kurir_nama, py.status AS payment_status, py.id AS payment_id,
               py.metode AS payment_metode,
               ca.nama_cabang AS cabang_asal_nama,
               ga.nama_cabang AS gateway_asal_nama,
               gt.nama_cabang AS gateway_tujuan_nama
        FROM paket p
        JOIN users u   ON p.pengirim_id     = u.id
        JOIN layanan l ON p.layanan_id      = l.id
        JOIN cabang ca ON p.cabang_asal_id  = ca.id
        LEFT JOIN cabang ga ON p.gateway_id         = ga.id
        LEFT JOIN cabang gt ON p.gateway_tujuan_id  = gt.id
        LEFT JOIN users k   ON p.kurir_id           = k.id
        LEFT JOIN pembayaran py ON py.paket_id      = p.id
        WHERE p.cabang_asal_id = %s OR p.gateway_id = %s OR p.gateway_tujuan_id = %s
        ORDER BY p.created_at DESC LIMIT 50
    """, (cabang_id, cabang_id, cabang_id))
    pakets = cur.fetchall()

    cur.execute("""SELECT COUNT(*) as total FROM paket p JOIN layanan l ON p.layanan_id=l.id
        WHERE (p.cabang_asal_id=%(id)s OR p.gateway_id=%(id)s OR p.gateway_tujuan_id=%(id)s)
          AND p.status NOT IN ('delivered','returned','failed_delivery')
          AND DATEDIFF(NOW(), p.created_at) > l.estimasi_hari""", {'id': cabang_id})
    total_terlambat = cur.fetchone()['total']

    # Kurir yang terdaftar di cabang/gateway ini (untuk assign saat out_for_delivery)
    cur.execute("SELECT * FROM users WHERE role='kurir' AND cabang_id=%s AND status='aktif'", (cabang_id,))
    kurirs = cur.fetchall()

    # Driver antar kota (untuk assign saat in_transit_gateway & on_transit)
    cur.execute("SELECT * FROM users WHERE role='driver' AND status='aktif'")
    drivers = cur.fetchall()

    cur.execute("SELECT * FROM layanan WHERE status='aktif'")
    layanans = cur.fetchall()

    cur.execute("SELECT * FROM cabang WHERE tipe IN ('gateway','pusat') AND status='aktif'")
    gateways = cur.fetchall()

    paket_allowed = {p['id']: get_allowed_status_for_admin(cabang_id, p) for p in pakets}

    cur.close()
    return render_template('admin/dashboard.html',
        cabang=cabang, total=total, delivered=delivered, on_delivery=on_delivery,
        total_terlambat=total_terlambat, pendapatan_cabang=pendapatan_cabang,
        pakets=pakets, kurirs=kurirs, drivers=drivers, layanans=layanans, gateways=gateways,
        paket_allowed=paket_allowed, STATUS_LABEL=STATUS_LABEL)


@app.route('/admin/tambah-pengiriman', methods=['GET', 'POST'])
@role_required('admin_cabang')
def admin_tambah_pengiriman():
    cabang_id = session['cabang_id']
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM cabang WHERE id=%s", (cabang_id,))
    cabang = cur.fetchone()
    cur.execute("SELECT * FROM layanan WHERE status='aktif'")
    layanans = cur.fetchall()
    # Hanya gateway dan pusat yang bisa jadi titik sortir
    cur.execute("SELECT * FROM cabang WHERE tipe IN ('gateway','pusat') AND status='aktif'")
    gateways = cur.fetchall()
    cur.close()
    if request.method == 'POST':
        return _proses_buat_paket(redirect_ke='admin_tambah_pengiriman')
    return render_template('admin/tambah_pengiriman.html',
        cabang=cabang, layanans=layanans, gateways=gateways)


def _proses_buat_paket(redirect_ke='admin_dashboard'):
    """
    Membuat paket baru.

    Alur yang terbentuk setelah paket dibuat:
      Cabang Asal → Gateway Kota Asal → Gateway Kota Tujuan → Kurir → Penerima

    Kurir di-assign oleh admin Gateway Tujuan, lalu antar langsung ke penerima
    saat mengubah status ke out_for_delivery.
    """
    cabang_id = session['cabang_id']
    cur = mysql.connection.cursor()
    try:
        cur.execute("SELECT kode_cabang, kota, provinsi, id FROM cabang WHERE id=%s", (cabang_id,))
        cabang = cur.fetchone()

        email_pengirim       = request.form.get('email_pengirim', '').strip()
        nama_pengirim_manual = request.form.get('nama_pengirim', '').strip()
        no_hp_pengirim       = request.form.get('no_hp_pengirim', '').strip()
        pengirim = None
        if email_pengirim:
            cur.execute("SELECT * FROM users WHERE email=%s", (email_pengirim,))
            pengirim = cur.fetchone()
        if not pengirim:
            if not nama_pengirim_manual:
                flash('❌ Isi nama pengirim jika email tidak terdaftar.', 'danger')
                cur.close()
                return redirect(url_for(redirect_ke))
            tamu_email = email_pengirim or f"tamu_{datetime.now().strftime('%y%m%d%H%M%S')}@tamu.local"
            cur.execute("INSERT INTO users (nama, email, password, role, no_hp) VALUES (%s,%s,'nologin','pengirim_tamu',%s)",
                        (nama_pengirim_manual, tamu_email, no_hp_pengirim))
            mysql.connection.commit()
            pengirim_id = cur.lastrowid
        else:
            pengirim_id = pengirim['id']

        layanan_id = request.form.get('layanan_id', '')
        if not layanan_id:
            flash('❌ Pilih layanan pengiriman.', 'danger')
            cur.close()
            return redirect(url_for(redirect_ke))
        cur.execute("SELECT * FROM layanan WHERE id=%s", (layanan_id,))
        layanan = cur.fetchone()
        if not layanan:
            flash('❌ Layanan tidak valid.', 'danger')
            cur.close()
            return redirect(url_for(redirect_ke))

        berat        = float(request.form.get('berat', 0) or 0)
        p_val        = float(request.form.get('panjang', 0) or 0)
        l_val        = float(request.form.get('lebar', 0) or 0)
        t_val        = float(request.form.get('tinggi', 0) or 0)
        nilai_barang = float(request.form.get('nilai_barang', 0) or 0)
        jalur        = request.form.get('jalur', 'darat')
        packing_kayu = request.form.get('packing_kayu') == '1'

        #  layanan JTR (min. 10 kg)
        kode_layanan = (layanan.get('kode') or '').upper()
        is_jtr       = 'JTR' in kode_layanan
        if is_jtr and berat < 10:
            flash(f'\u274c Layanan {layanan["kode"]} (JTR) membutuhkan berat paket minimal 10 kg. '
                  f'Berat yang diinput: {berat} kg.', 'danger')
            cur.close()
            return redirect(url_for(redirect_ke))

        berat_vol    = hitung_berat_volumetrik(p_val, l_val, t_val, jalur)
        berat_bayar  = max(berat, berat_vol)
        biaya_kirim, biaya_asuransi, total_biaya = hitung_biaya(
            berat_bayar, float(layanan['harga_per_kg']), nilai_barang)

        # Biaya tambahan JTR: admin Rp5.000
        biaya_admin        = 5000 if is_jtr else 0
        # Biaya tambahan opsional: packing kayu Rp5.000
        biaya_packing_kayu = 5000 if packing_kayu else 0
        total_biaya        = round(total_biaya + biaya_admin + biaya_packing_kayu, 2)

        no_resi     = generate_resi(cabang['kode_cabang'])
        kota_tujuan = request.form.get('kota_tujuan', '').strip()

        # ── Gateway Kota Asal (auto atau manual) ────────────────────────────
        gw_asal_form = request.form.get('gateway_id')
        gateway_id   = int(gw_asal_form) if gw_asal_form else None
        if not gateway_id:
            cur.execute("""SELECT id FROM cabang WHERE tipe IN ('gateway','pusat') AND status='aktif'
                AND provinsi=(SELECT provinsi FROM cabang WHERE id=%s)
                ORDER BY tipe='gateway' DESC LIMIT 1""", (cabang_id,))
            gw = cur.fetchone() or {}
            if not gw:
                cur.execute("SELECT id FROM cabang WHERE tipe IN ('gateway','pusat') AND status='aktif' ORDER BY tipe='pusat' DESC LIMIT 1")
                gw = cur.fetchone() or {}
            gateway_id = gw.get('id')

        # ── Gateway Kota Tujuan (auto atau manual) ───────────────────────────
        gw_tujuan_form    = request.form.get('gateway_tujuan_id')
        gateway_tujuan_id = int(gw_tujuan_form) if gw_tujuan_form else None

        # Cek apakah pengiriman dalam kota yang sama (lokal / sekota)
        kota_asal_cabang = cabang['kota']
        is_lokal = (kota_asal_cabang.strip().lower() == kota_tujuan.strip().lower())

        # Paket lokal tetap wajib melalui gateway kota asal
        if is_lokal and not gateway_id:
            flash('❌ Tidak ditemukan gateway di kota ini. Paket lokal tetap wajib melalui gateway kota asal.', 'danger')
            cur.close()
            return redirect(url_for(redirect_ke))

        if not gateway_tujuan_id:
            if is_lokal:
                # Paket sekota: gateway tujuan = gateway asal (gateway kota yang sama)
                gateway_tujuan_id = gateway_id
            elif kota_tujuan:
                # Cari gateway yang berada di kota tujuan
                cur.execute("""SELECT id FROM cabang WHERE tipe IN ('gateway','pusat') AND status='aktif'
                    AND kota=%s LIMIT 1""", (kota_tujuan,))
                gw_t = cur.fetchone()
                if not gw_t:
                    # Fallback: gateway manapun (admin bisa edit manual)
                    cur.execute("SELECT id FROM cabang WHERE tipe IN ('gateway','pusat') AND status='aktif' ORDER BY tipe='gateway' DESC LIMIT 1")
                    gw_t = cur.fetchone()
                gateway_tujuan_id = gw_t['id'] if gw_t else None
        metode_bayar  = request.form.get('metode_bayar', 'tunai')  # tunai / xendit
        status_bayar  = request.form.get('status_bayar', 'pending')

        cur.execute("""
            INSERT INTO paket (
                no_resi, pengirim_id, nama_penerima, no_hp_penerima, alamat_penerima,
                kota_asal, kota_tujuan, cabang_asal_id,
                gateway_id, gateway_tujuan_id, layanan_id,
                berat, panjang, lebar, tinggi, berat_volume, berat_bayar,
                isi_paket, nilai_barang, biaya_kirim, biaya_asuransi, total_biaya, jalur, status
            ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, (
            no_resi, pengirim_id,
            request.form.get('nama_penerima', ''), request.form.get('no_hp_penerima', ''),
            request.form.get('alamat_penerima', ''),
            cabang['kota'], kota_tujuan,
            cabang_id,
            gateway_id, gateway_tujuan_id,
            layanan_id, berat, p_val, l_val, t_val, berat_vol, berat_bayar,
            request.form.get('isi_paket', ''), nilai_barang,
            biaya_kirim, biaya_asuransi, total_biaya, jalur, 'created',
        ))
        paket_id = cur.lastrowid
        mysql.connection.commit()

        # ── Simpan record pembayaran ──────────────────────────────
        xendit_invoice_id  = None
        xendit_invoice_url = None
        xendit_external_id = None
        metode_final = metode_bayar

        if metode_bayar == 'xendit':
            # Buat invoice Xendit — metode final ditentukan payer
            try:
                nama_pengirim = request.form.get('nama_pengirim', 'Pengirim')
                xinv = create_xendit_invoice(paket_id, no_resi, total_biaya, nama_pengirim)
                xendit_invoice_id  = xinv['invoice_id']
                xendit_invoice_url = xinv['invoice_url']
                xendit_external_id = xinv['external_id']
                metode_final = 'transfer'  # placeholder; diperbarui saat webhook
                status_bayar = 'pending'
            except Exception as xe:
                flash(f'⚠️ Paket dibuat, tapi gagal buat invoice Xendit: {xe}', 'warning')
                xendit_invoice_id = None

        cur.execute(
            """INSERT INTO pembayaran
               (paket_id, jumlah, metode, status, dicatat_oleh,
                xendit_invoice_id, xendit_invoice_url, xendit_external_id)
               VALUES (%s,%s,%s,%s,%s,%s,%s,%s)""",
            (paket_id, total_biaya, metode_final, status_bayar,
             session['user_id'], xendit_invoice_id, xendit_invoice_url, xendit_external_id)
        )
        mysql.connection.commit()

        ket = f'Paket diterima di cabang {cabang["kota"]}. Layanan: {layanan["nama"]}'
        if is_lokal:      ket += ' | PAKET LOKAL (Sekota - tetap via Gateway)'
        if is_jtr:        ket += ' | JTR (+ Biaya Admin Rp5.000)'
        if packing_kayu:  ket += ' | Packing Kayu (+ Rp5.000)'
        if metode_bayar == 'xendit' and xendit_invoice_url:
            ket += ' | Pembayaran Non-Tunai (Xendit)'
        add_tracking(paket_id, 'created', ket, cabang['kota'], session['user_id'])

        cur.close()

        if metode_bayar == 'xendit' and xendit_invoice_url:
            flash(f'✅ Paket berhasil dibuat! No Resi: {no_resi}. Link pembayaran: {xendit_invoice_url}', 'success')
        else:
            flash(f'✅ Paket berhasil dibuat! No Resi: {no_resi}', 'success')
    except Exception as e:
        mysql.connection.rollback()
        cur.close()
        flash(f'❌ Terjadi kesalahan: {str(e)}', 'danger')
    return redirect(url_for(redirect_ke))

@app.route('/api/cek-harga')
def api_cek_harga():
    berat = float(request.args.get('berat', 1))
    layanan_id = request.args.get('layanan_id')
    nilai = float(request.args.get('nilai', 0))
    jalur = request.args.get('jalur', 'darat')
    p_val = float(request.args.get('panjang', 0) or 0)
    l_val = float(request.args.get('lebar', 0) or 0)
    t_val = float(request.args.get('tinggi', 0) or 0)
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM layanan WHERE id=%s", (layanan_id,))
    l = cur.fetchone()
    cur.close()
    if not l:
        return jsonify({'error': 'Layanan tidak ditemukan'})
    berat_vol = hitung_berat_volumetrik(p_val, l_val, t_val, jalur)
    berat_bayar = max(berat, berat_vol)
    biaya_kirim, biaya_asuransi, total = hitung_biaya(berat_bayar, float(l['harga_per_kg']), nilai)
    divisor = 5000 if jalur == 'darat' else 6000
    return jsonify({'berat_aktual': berat, 'berat_volumetrik': berat_vol, 'berat_bayar': berat_bayar,
                    'divisor_dipakai': divisor, 'biaya_kirim': biaya_kirim,
                    'biaya_asuransi': biaya_asuransi, 'total': total, 'estimasi': l['estimasi_hari']})

@app.route('/admin/paket/update-status/<int:paket_id>', methods=['POST'])
@role_required('admin_cabang')
def admin_update_status(paket_id):
    cabang_id   = session['cabang_id']
    status_baru = request.form['status']
    keterangan  = request.form.get('keterangan', '')
    lokasi      = request.form.get('lokasi', '')
    kurir_id    = request.form.get('kurir_id') or None
    driver_id   = request.form.get('driver_id') or None

    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM paket WHERE id=%s", (paket_id,))
    paket = cur.fetchone()
    if not paket:
        flash('Paket tidak ditemukan.', 'danger')
        cur.close()
        return redirect(url_for('admin_dashboard'))

    allowed = get_allowed_status_for_admin(cabang_id, paket)
    if status_baru not in allowed:
        label = STATUS_LABEL.get(status_baru, (status_baru, ''))[0]
        flash(f'⛔ Status "{label}" tidak diizinkan untuk posisi Anda.', 'danger')
        cur.close()
        return redirect(url_for('admin_dashboard'))

    if kurir_id:
        cur.execute("UPDATE paket SET status=%s, kurir_id=%s WHERE id=%s", (status_baru, kurir_id, paket_id))
    elif driver_id and status_baru in ('in_transit_gateway', 'on_transit'):
        cur.execute("UPDATE paket SET status=%s, driver_id=%s WHERE id=%s", (status_baru, driver_id, paket_id))
    else:
        cur.execute("UPDATE paket SET status=%s WHERE id=%s", (status_baru, paket_id))
    mysql.connection.commit()

    add_tracking(paket_id, status_baru, keterangan, lokasi, session['user_id'])
    cur.close()
    flash('Status paket diperbarui.', 'success')
    return redirect(url_for('admin_dashboard'))


@app.route('/admin/payment')
@role_required('admin_cabang')
def admin_payment():
    cabang_id = session['cabang_id']
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM cabang WHERE id=%s", (cabang_id,))
    cabang = cur.fetchone()

    tgl_dari   = request.args.get('tgl_dari', '')
    tgl_sampai = request.args.get('tgl_sampai', '')

    date_filter_sql = ''
    date_params     = []
    if tgl_dari:
        date_filter_sql += ' AND DATE(py.created_at) >= %s'
        date_params.append(tgl_dari)
    if tgl_sampai:
        date_filter_sql += ' AND DATE(py.created_at) <= %s'
        date_params.append(tgl_sampai)

    cur.execute(f"""SELECT py.*, p.no_resi, p.kota_tujuan, p.total_biaya,
               u.nama AS pengirim_nama, l.kode AS layanan_kode, pu.nama AS dicatat_oleh_nama
        FROM pembayaran py JOIN paket p ON py.paket_id=p.id JOIN users u ON p.pengirim_id=u.id
        JOIN layanan l ON p.layanan_id=l.id LEFT JOIN users pu ON py.dicatat_oleh=pu.id
        WHERE (p.cabang_asal_id=%s OR p.gateway_id=%s OR p.gateway_tujuan_id=%s)
        {date_filter_sql}
        ORDER BY py.created_at DESC""",
        [cabang_id, cabang_id, cabang_id] + date_params)
    payments = cur.fetchall()

    cur.execute(f"""SELECT COALESCE(SUM(py.jumlah),0) AS total,
               COALESCE(SUM(CASE WHEN py.status='lunas' THEN py.jumlah ELSE 0 END),0) AS lunas,
               COALESCE(SUM(CASE WHEN py.status='pending' THEN py.jumlah ELSE 0 END),0) AS pending
        FROM pembayaran py JOIN paket p ON py.paket_id=p.id
        WHERE p.cabang_asal_id=%s {date_filter_sql}""",
        [cabang_id] + date_params)
    rekap = cur.fetchone()
    cur.close()
    return render_template('admin/payment.html',
        cabang=cabang, payments=payments, rekap=rekap,
        tgl_dari=tgl_dari, tgl_sampai=tgl_sampai)


@app.route('/admin/payment/update/<int:pay_id>', methods=['POST'])
@role_required('admin_cabang')
def admin_payment_update(pay_id):
    status_baru = request.form.get('status')
    cur = mysql.connection.cursor()

    # Ambil info pembayaran & paket terkait
    cur.execute("""SELECT py.*, p.no_resi, p.pengirim_id, p.total_biaya
                   FROM pembayaran py JOIN paket p ON py.paket_id = p.id
                   WHERE py.id = %s""", (pay_id,))
    pay = cur.fetchone()

    # Metode bisa diubah admin (tunai/transfer/qris/virtual_account)
    metode_baru = request.form.get('metode', pay['metode'] if pay else 'tunai')
    cur.execute("UPDATE pembayaran SET status=%s, metode=%s, dicatat_oleh=%s WHERE id=%s",
                (status_baru, metode_baru, session['user_id'], pay_id))
    mysql.connection.commit()

    cur.close()

    if status_baru == 'lunas':
        flash('✅ Pembayaran dikonfirmasi lunas!', 'success')
    elif status_baru == 'pending':
        flash('⏳ Status pembayaran disimpan sebagai Pending.', 'warning')
    else:
        flash('Status pembayaran diperbarui.', 'info')

    return redirect(url_for('admin_payment'))


@app.route('/kurir')
@role_required('kurir')
def kurir_dashboard():
    user_id = session['user_id']
    cur = mysql.connection.cursor()
    cur.execute("""SELECT p.*, u.nama AS pengirim, l.kode AS layanan_kode, l.estimasi_hari,
           gt.nama_cabang AS gateway_tujuan_nama,
           py.metode AS payment_metode, py.status AS payment_status, py.jumlah AS payment_jumlah
    FROM paket p JOIN users u ON p.pengirim_id=u.id JOIN layanan l ON p.layanan_id=l.id
    LEFT JOIN cabang gt ON p.gateway_tujuan_id=gt.id
    LEFT JOIN (
        SELECT paket_id, metode, status, jumlah
        FROM pembayaran
        WHERE id IN (SELECT MAX(id) FROM pembayaran GROUP BY paket_id)
    ) py ON py.paket_id = p.id
    WHERE p.kurir_id=%s ORDER BY p.updated_at DESC""", (user_id,))
    pakets = cur.fetchall()
    cur.execute("SELECT COUNT(*) as t FROM paket WHERE kurir_id=%s AND status='out_for_delivery'", (user_id,))
    on_delivery = cur.fetchone()['t']
    cur.execute("SELECT COUNT(*) as t FROM paket WHERE kurir_id=%s AND status='delivered'", (user_id,))
    delivered = cur.fetchone()['t']
    cur.execute("SELECT COUNT(*) as t FROM paket WHERE kurir_id=%s AND status='failed_delivery'", (user_id,))
    failed = cur.fetchone()['t']
    cur.execute("""SELECT COUNT(*) as total FROM paket p JOIN layanan l ON p.layanan_id=l.id
        WHERE p.kurir_id=%s AND p.status NOT IN ('delivered','returned','failed_delivery')
          AND DATEDIFF(NOW(), p.created_at) > l.estimasi_hari""", (user_id,))
    total_terlambat = cur.fetchone()['total']
    cur.close()
    return render_template('kurir/dashboard.html',
        pakets=pakets, on_delivery=on_delivery, delivered=delivered, failed=failed,
        total_terlambat=total_terlambat, STATUS_LABEL=STATUS_LABEL)


@app.route('/kurir/pod/<int:paket_id>', methods=['POST'])
@role_required('kurir')
def kurir_pod(paket_id):
    nama_penerima = request.form['nama_penerima']
    lokasi        = request.form.get('lokasi_display', 'Alamat Penerima')
    catatan_pod   = request.form.get('catatan_pod', '')
    foto_filename = None

    # ── Upload foto POD ──────────────────────────────────────
    foto_file = request.files.get('foto_pod')
    if foto_file and foto_file.filename and allowed_file(foto_file.filename):
        ext          = foto_file.filename.rsplit('.', 1)[1].lower()
        foto_filename = f"pod_{paket_id}_{uuid.uuid4().hex[:8]}.{ext}"
        save_path    = os.path.join(app.config['UPLOAD_FOLDER'], foto_filename)
        foto_file.save(save_path)

    cur = mysql.connection.cursor()
    cur.execute(
        """UPDATE paket SET status='delivered', pod_penerima=%s, pod_waktu=NOW(),
           pod_foto=%s, pod_catatan=%s WHERE id=%s AND kurir_id=%s""",
        (nama_penerima, foto_filename, catatan_pod, paket_id, session['user_id'])
    )
    mysql.connection.commit()
    ket = f'Paket diterima oleh {nama_penerima}'
    if catatan_pod: ket += f' | {catatan_pod}'
    if foto_filename: ket += ' | 📷 Foto POD tersimpan'
    add_tracking(paket_id, 'delivered', ket, lokasi, session['user_id'])
    cur.close()
    flash('✅ POD berhasil dikonfirmasi!', 'success')
    return redirect(url_for('kurir_dashboard'))


@app.route('/kurir/gagal/<int:paket_id>', methods=['POST'])
@role_required('kurir')
def kurir_gagal(paket_id):
    from datetime import datetime, timedelta
    alasan = request.form.get('alasan', '')
    lokasi    = request.form.get('lokasi_display', 'Alamat Penerima')
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM paket WHERE id=%s AND kurir_id=%s", (paket_id, session['user_id']))
    paket = cur.fetchone()
    if not paket or paket['status'] != 'out_for_delivery':
        flash('Tidak dapat melaporkan gagal untuk paket ini.', 'danger')
        cur.close()
        return redirect(url_for('kurir_dashboard'))

    # Hitung jumlah percobaan gagal sebelumnya dari riwayat tracking
    cur.execute(
        "SELECT COUNT(*) as total FROM riwayat_paket WHERE paket_id=%s AND status='failed_delivery'",
        (paket_id,)
    )
    gagal_sebelumnya = cur.fetchone()['total']
    percobaan_ke = gagal_sebelumnya + 1  # percobaan saat ini

    add_tracking(paket_id, 'failed_delivery',
                 f'Gagal antar (percobaan ke-{percobaan_ke}): {alasan}',
                 lokasi, session['user_id'])

    if percobaan_ke >= 3:
        # Setelah 3x gagal: masuk masa Hold 3 hari, BUKAN langsung retur
        hold_until = datetime.now() + timedelta(days=3)
        cur.execute(
            "UPDATE paket SET status='on_hold', hold_until=%s WHERE id=%s",
            (hold_until, paket_id)
        )
        mysql.connection.commit()
        add_tracking(paket_id, 'on_hold',
                     f'Paket masuk masa Hold selama 3 hari hingga {hold_until.strftime("%d %b %Y")}. '
                     f'Retur akan diproses setelah masa hold berakhir.',
                     'Gudang Cabang', session['user_id'])
        flash(f'⚠️ Paket telah gagal diantar 3 kali. Paket masuk masa Hold selama 3 hari '
              f'hingga {hold_until.strftime("%d %b %Y")}. Retur diproses setelah masa hold berakhir.',
              'warning')
    else:
        cur.execute("UPDATE paket SET status='failed_delivery' WHERE id=%s", (paket_id,))
        mysql.connection.commit()
        sisa = 3 - percobaan_ke
        flash(f'⚠️ Laporan gagal antar disimpan (percobaan ke-{percobaan_ke}/3). '
              f'Sisa {sisa} percobaan sebelum paket masuk masa Hold.', 'warning')

    cur.close()
    return redirect(url_for('kurir_dashboard'))


@app.route('/kurir/reschedule/<int:paket_id>', methods=['POST'])
@role_required('kurir')
def kurir_reschedule(paket_id):
    from datetime import datetime
    catatan = request.form.get('catatan', 'Dijadwalkan ulang')
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM paket WHERE id=%s AND kurir_id=%s", (paket_id, session['user_id']))
    paket = cur.fetchone()
    if not paket or paket['status'] not in ('failed_delivery', 'on_hold'):
        flash('Tidak dapat menjadwalkan ulang paket ini.', 'danger')
        cur.close()
        return redirect(url_for('kurir_dashboard'))

    # Jika paket sedang on_hold, cek apakah masa hold sudah berakhir
    if paket['status'] == 'on_hold':
        hold_until = paket.get('hold_until')
        if hold_until and datetime.now() < hold_until:
            sisa = (hold_until - datetime.now()).days + 1
            flash(f'🔒 Paket masih dalam masa Hold. Masa hold berakhir pada '
                  f'{hold_until.strftime("%d %b %Y")} (sekitar {sisa} hari lagi). '
                  f'Paket akan diproses retur setelah masa hold selesai.', 'danger')
            cur.close()
            return redirect(url_for('kurir_dashboard'))
        # Masa hold sudah berakhir → lanjut ke retur otomatis
        cur.execute("UPDATE paket SET status='return_process' WHERE id=%s", (paket_id,))
        mysql.connection.commit()
        add_tracking(paket_id, 'return_process',
                     'Masa Hold berakhir. Paket otomatis diproses retur ke cabang asal.',
                     'Gudang Cabang', session['user_id'])
        flash('🔄 Masa Hold berakhir. Paket otomatis diproses retur ke cabang asal.', 'info')
        cur.close()
        return redirect(url_for('kurir_dashboard'))

    cur.execute("UPDATE paket SET status='out_for_delivery' WHERE id=%s", (paket_id,))
    mysql.connection.commit()
    add_tracking(paket_id, 'out_for_delivery', f'Dijadwalkan ulang: {catatan}', '', session['user_id'])
    cur.close()
    flash('Paket dijadwalkan ulang untuk diantar.', 'info')
    return redirect(url_for('kurir_dashboard'))


@app.route('/kurir/retur/<int:paket_id>', methods=['POST'])
@role_required('kurir')
def kurir_retur(paket_id):
    from datetime import datetime
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM paket WHERE id=%s AND kurir_id=%s", (paket_id, session['user_id']))
    paket = cur.fetchone()
    if not paket or paket['status'] not in ('failed_delivery', 'on_hold'):
        flash('Tidak dapat memproses retur paket ini.', 'danger')
        cur.close()
        return redirect(url_for('kurir_dashboard'))

    # Jika masih dalam masa hold, retur manual tidak diizinkan
    if paket['status'] == 'on_hold':
        hold_until = paket.get('hold_until')
        if hold_until and datetime.now() < hold_until:
            flash(f'🔒 Paket masih dalam masa Hold hingga {hold_until.strftime("%d %b %Y")}. '
                  f'Retur hanya dapat diproses setelah masa hold berakhir.', 'danger')
            cur.close()
            return redirect(url_for('kurir_dashboard'))

    cur.execute("UPDATE paket SET status='return_process' WHERE id=%s", (paket_id,))
    mysql.connection.commit()
    add_tracking(paket_id, 'return_process', 'Paket dikembalikan ke cabang asal', '', session['user_id'])
    cur.close()
    flash('🔁 Paket dalam proses retur ke cabang asal.', 'info')
    return redirect(url_for('kurir_dashboard'))



@app.route('/driver')
@role_required('driver')
def driver_dashboard():
    user_id = session['user_id']
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT p.*, u.nama AS pengirim_nama, l.kode AS layanan_kode, l.estimasi_hari,
               ca.nama_cabang AS cabang_asal_nama,
               ga.nama_cabang AS gateway_asal_nama,
               gt.nama_cabang AS gateway_tujuan_nama,
               py.status AS payment_status
        FROM paket p
        JOIN users u   ON p.pengirim_id       = u.id
        JOIN layanan l ON p.layanan_id         = l.id
        JOIN cabang ca ON p.cabang_asal_id     = ca.id
        LEFT JOIN cabang ga ON p.gateway_id         = ga.id
        LEFT JOIN cabang gt ON p.gateway_tujuan_id  = gt.id
        LEFT JOIN (
            SELECT paket_id, status
            FROM pembayaran
            WHERE id IN (SELECT MAX(id) FROM pembayaran GROUP BY paket_id)
        ) py ON py.paket_id = p.id
        WHERE p.driver_id = %s AND p.status IN ('in_transit_gateway','on_transit','arrived_gateway_dest')
        ORDER BY p.updated_at DESC
    """, (user_id,))
    pakets_aktif = cur.fetchall()

    cur.execute("""
        SELECT p.*, u.nama AS pengirim_nama, l.kode AS layanan_kode,
               ca.nama_cabang AS cabang_asal_nama,
               ga.nama_cabang AS gateway_asal_nama,
               gt.nama_cabang AS gateway_tujuan_nama
        FROM paket p
        JOIN users u   ON p.pengirim_id       = u.id
        JOIN layanan l ON p.layanan_id         = l.id
        JOIN cabang ca ON p.cabang_asal_id     = ca.id
        LEFT JOIN cabang ga ON p.gateway_id         = ga.id
        LEFT JOIN cabang gt ON p.gateway_tujuan_id  = gt.id
        WHERE p.driver_id = %s AND p.status NOT IN ('in_transit_gateway','on_transit','arrived_gateway_dest')
        ORDER BY p.updated_at DESC LIMIT 30
    """, (user_id,))
    riwayat = cur.fetchall()

    cur.execute("SELECT COUNT(*) as t FROM paket WHERE driver_id=%s AND status IN ('in_transit_gateway','on_transit')", (user_id,))
    sedang_jalan = cur.fetchone()['t']
    cur.execute("SELECT COUNT(*) as t FROM paket WHERE driver_id=%s AND status='arrived_gateway_dest'", (user_id,))
    sudah_tiba = cur.fetchone()['t']
    cur.execute("SELECT COUNT(*) as t FROM paket WHERE driver_id=%s", (user_id,))
    total_paket = cur.fetchone()['t']
    cur.close()

    return render_template('driver/dashboard.html',
        pakets_aktif=pakets_aktif, riwayat=riwayat,
        sedang_jalan=sedang_jalan, sudah_tiba=sudah_tiba, total_paket=total_paket,
        STATUS_LABEL=STATUS_LABEL)


@app.route('/driver/konfirmasi-transit/<int:paket_id>', methods=['POST'])
@role_required('driver')
def driver_konfirmasi_transit(paket_id):
    """Driver konfirmasi paket sudah diambil / sudah tiba di tujuan."""
    aksi   = request.form.get('aksi')   # 'pickup' atau 'arrived'
    catatan = request.form.get('catatan', '')
    user_id = session['user_id']

    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM paket WHERE id=%s AND driver_id=%s", (paket_id, user_id))
    paket = cur.fetchone()
    if not paket:
        flash('Paket tidak ditemukan atau bukan milik Anda.', 'danger')
        cur.close()
        return redirect(url_for('driver_dashboard'))

    if aksi == 'pickup' and paket['status'] == 'in_transit_gateway':
        # Cabang → Gateway Asal: driver sudah pickup, status tetap in_transit_gateway
        # tapi kita catat di riwayat bahwa paket sudah diambil driver
        add_tracking(paket_id, 'in_transit_gateway',
                     f'Paket diambil driver untuk dikirim ke Gateway. {catatan}',
                     paket.get('kota_asal', ''), user_id)
        flash('✅ Konfirmasi pickup berhasil dicatat.', 'success')

    elif aksi == 'pickup' and paket['status'] == 'on_transit':
        # Gateway Asal → Gateway Tujuan: driver sudah pickup dari gateway asal
        add_tracking(paket_id, 'on_transit',
                     f'Paket diambil driver, dalam perjalanan antar kota. {catatan}',
                     paket.get('', ''), user_id)
        flash('✅ Konfirmasi pickup antar kota berhasil dicatat.', 'success')

    elif aksi == 'arrived' and paket['status'] == 'in_transit_gateway':
        # Tiba di gateway asal
        cur.execute("UPDATE paket SET status='gateway_origin' WHERE id=%s", (paket_id,))
        mysql.connection.commit()
        add_tracking(paket_id, 'gateway_origin',
                     f'Paket tiba di Gateway Kota Asal. {catatan}',
                     paket.get('kota_asal', ''), user_id)
        flash('✅ Paket berhasil diantarkan ke Gateway Kota Asal.', 'success')

    elif aksi == 'arrived' and paket['status'] == 'on_transit':
        # Tiba di gateway tujuan
        cur.execute("UPDATE paket SET status='arrived_gateway_dest' WHERE id=%s", (paket_id,))
        mysql.connection.commit()
        add_tracking(paket_id, 'arrived_gateway_dest',
                     f'Paket tiba di Gateway Kota Tujuan. {catatan}',
                     paket.get('kota_tujuan', ''), user_id)
        flash('✅ Paket berhasil diantarkan ke Gateway Kota Tujuan.', 'success')
    else:
        flash('Aksi tidak valid untuk status paket saat ini.', 'danger')

    cur.close()
    return redirect(url_for('driver_dashboard'))


@app.route('/driver/riwayat')
@role_required('driver')
def driver_riwayat():
    user_id = session['user_id']
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT p.*, u.nama AS pengirim_nama, l.kode AS layanan_kode,
               ca.nama_cabang AS cabang_asal_nama,
               ga.nama_cabang AS gateway_asal_nama,
               gt.nama_cabang AS gateway_tujuan_nama
        FROM paket p
        JOIN users u   ON p.pengirim_id   = u.id
        JOIN layanan l ON p.layanan_id    = l.id
        JOIN cabang ca ON p.cabang_asal_id = ca.id
        LEFT JOIN cabang ga ON p.gateway_id        = ga.id
        LEFT JOIN cabang gt ON p.gateway_tujuan_id = gt.id
        WHERE p.driver_id = %s ORDER BY p.updated_at DESC
    """, (user_id,))
    pakets = cur.fetchall()
    cur.close()
    return render_template('driver/riwayat.html', pakets=pakets, STATUS_LABEL=STATUS_LABEL)



@app.route('/kurir/bulk-pod', methods=['POST'])
@role_required('kurir')
def kurir_bulk_pod():
    """Konfirmasi terkirim (POD) untuk banyak paket sekaligus."""
    user_id      = session['user_id']
    nama_terima  = request.form.get('nama_penerima', '').strip() or 'Penerima'
    paket_ids    = request.form.getlist('paket_ids')
    sukses = ditolak = 0
    cur = mysql.connection.cursor()
    for pid in paket_ids:
        try: pid = int(pid)
        except ValueError: continue
        cur.execute("SELECT * FROM paket WHERE id=%s AND kurir_id=%s AND status='out_for_delivery'",
                    (pid, user_id))
        p = cur.fetchone()
        if not p: ditolak += 1; continue
        cur.execute("UPDATE paket SET status='delivered', pod_penerima=%s, pod_waktu=NOW() WHERE id=%s",
                    (nama_terima, pid))
        mysql.connection.commit()
        add_tracking(pid, 'delivered', f'Paket diterima oleh {nama_terima}', p.get('alamat_penerima',''), user_id)
        sukses += 1
    cur.close()
    if sukses: flash(f'✅ {sukses} paket berhasil dikonfirmasi terkirim (POD).', 'success')
    if ditolak: flash(f'⚠️ {ditolak} paket dilewati (status tidak sesuai atau bukan milik Anda).', 'warning')
    return redirect(url_for('kurir_dashboard'))


@app.route('/kurir/bulk-gagal', methods=['POST'])
@role_required('kurir')
def kurir_bulk_gagal():
    """Laporan gagal antar untuk banyak paket sekaligus."""
    from datetime import timedelta
    user_id  = session['user_id']
    alasan   = request.form.get('alasan', 'Penerima tidak ada di tempat')
    paket_ids = request.form.getlist('paket_ids')
    sukses = ditolak = 0
    cur = mysql.connection.cursor()
    for pid in paket_ids:
        try: pid = int(pid)
        except ValueError: continue
        cur.execute("SELECT * FROM paket WHERE id=%s AND kurir_id=%s AND status='out_for_delivery'",
                    (pid, user_id))
        p = cur.fetchone()
        if not p: ditolak += 1; continue

        cur.execute("SELECT COUNT(*) as total FROM riwayat_status WHERE paket_id=%s AND status='failed_delivery'",
                    (pid,))
        gagal_sebelumnya = cur.fetchone()['total']
        percobaan_ke = gagal_sebelumnya + 1

        add_tracking(pid, 'failed_delivery',
                     f'Gagal antar (percobaan ke-{percobaan_ke}): {alasan}',
                     p.get('alamat_penerima',''), user_id)

        if percobaan_ke >= 3:
            hold_until = datetime.now() + timedelta(days=3)
            cur.execute("UPDATE paket SET status='on_hold', hold_until=%s WHERE id=%s", (hold_until, pid))
            mysql.connection.commit()
            add_tracking(pid, 'on_hold',
                         f'Paket masuk masa Hold 3 hari hingga {hold_until.strftime("%d %b %Y")}.',
                         'Gudang Cabang', user_id)
        else:
            cur.execute("UPDATE paket SET status='failed_delivery' WHERE id=%s", (pid,))
            mysql.connection.commit()
        sukses += 1
    cur.close()
    if sukses: flash(f'⚠️ {sukses} paket dilaporkan gagal antar.', 'warning')
    if ditolak: flash(f'ℹ️ {ditolak} paket dilewati.', 'info')
    return redirect(url_for('kurir_dashboard'))


@app.route('/kurir/bulk-reschedule', methods=['POST'])
@role_required('kurir')
def kurir_bulk_reschedule():
    """Jadwal ulang untuk banyak paket gagal sekaligus."""
    user_id   = session['user_id']
    catatan   = request.form.get('catatan', 'Dijadwalkan ulang')
    paket_ids = request.form.getlist('paket_ids')
    sukses = ditolak = 0
    cur = mysql.connection.cursor()
    for pid in paket_ids:
        try: pid = int(pid)
        except ValueError: continue
        cur.execute("SELECT * FROM paket WHERE id=%s AND kurir_id=%s AND status='failed_delivery'",
                    (pid, user_id))
        p = cur.fetchone()
        if not p: ditolak += 1; continue
        cur.execute("UPDATE paket SET status='out_for_delivery' WHERE id=%s", (pid,))
        mysql.connection.commit()
        add_tracking(pid, 'out_for_delivery', f'Dijadwalkan ulang: {catatan}', '', user_id)
        sukses += 1
    cur.close()
    if sukses: flash(f'🔄 {sukses} paket dijadwalkan ulang.', 'info')
    if ditolak: flash(f'⚠️ {ditolak} paket dilewati.', 'warning')
    return redirect(url_for('kurir_dashboard'))



@app.route('/driver/bulk-konfirmasi', methods=['POST'])
@role_required('driver')
def driver_bulk_konfirmasi():
    """Bulk pickup atau bulk tiba untuk driver."""
    user_id   = session['user_id']
    aksi      = request.form.get('aksi')          # 'pickup' atau 'arrived'
    catatan   = request.form.get('catatan', '')
    paket_ids = request.form.getlist('paket_ids')
    sukses = ditolak = 0

    if aksi not in ('pickup', 'arrived'):
        flash('❌ Aksi tidak valid.', 'danger')
        return redirect(url_for('driver_dashboard'))

    cur = mysql.connection.cursor()
    for pid in paket_ids:
        try: pid = int(pid)
        except ValueError: continue
        cur.execute("SELECT * FROM paket WHERE id=%s AND driver_id=%s", (pid, user_id))
        p = cur.fetchone()
        if not p or p['status'] not in ('in_transit_gateway', 'on_transit'):
            ditolak += 1; continue

        if aksi == 'pickup':
            add_tracking(pid, p['status'],
                         f'Paket diambil driver (bulk). {catatan}',
                         p.get('kota_asal',''), user_id)
        elif aksi == 'arrived':
            if p['status'] == 'in_transit_gateway':
                cur.execute("UPDATE paket SET status='gateway_origin' WHERE id=%s", (pid,))
                mysql.connection.commit()
                add_tracking(pid, 'gateway_origin',
                             f'Tiba di Gateway Kota Asal (bulk). {catatan}',
                             p.get('kota_asal',''), user_id)
            elif p['status'] == 'on_transit':
                cur.execute("UPDATE paket SET status='arrived_gateway_dest' WHERE id=%s", (pid,))
                mysql.connection.commit()
                add_tracking(pid, 'arrived_gateway_dest',
                             f'Tiba di Gateway Kota Tujuan (bulk). {catatan}',
                             p.get('kota_tujuan',''), user_id)
        sukses += 1
    cur.close()

    label = 'Pickup' if aksi == 'pickup' else 'Tiba di Tujuan'
    if sukses: flash(f'✅ {sukses} paket dikonfirmasi: {label}.', 'success')
    if ditolak: flash(f'⚠️ {ditolak} paket dilewati (status tidak sesuai).', 'warning')
    return redirect(url_for('driver_dashboard'))


@app.route('/admin/paket/bulk-update', methods=['POST'])
@role_required('admin_cabang')
def admin_bulk_update_status():
    """
    Bulk update status untuk banyak paket sekaligus.
    Hanya paket yang benar-benar diizinkan (sesuai get_allowed_status_for_admin) yang diproses.
    """
    cabang_id   = session['cabang_id']
    status_baru = request.form.get('status')
    keterangan  = request.form.get('keterangan', '')
    lokasi      = request.form.get('lokasi', '')
    kurir_id    = request.form.get('kurir_id') or None
    driver_id   = request.form.get('driver_id') or None
    paket_ids   = request.form.getlist('paket_ids')  # list of str IDs

    if not status_baru or not paket_ids:
        flash('❌ Pilih minimal 1 paket dan status tujuan.', 'danger')
        return redirect(url_for('admin_dashboard'))

    cur = mysql.connection.cursor()
    sukses, ditolak = 0, 0

    for pid in paket_ids:
        try:
            pid = int(pid)
        except ValueError:
            continue

        cur.execute("SELECT * FROM paket WHERE id=%s", (pid,))
        paket = cur.fetchone()
        if not paket:
            ditolak += 1
            continue

        allowed = get_allowed_status_for_admin(cabang_id, paket)
        if status_baru not in allowed:
            ditolak += 1
            continue

        if kurir_id and status_baru == 'out_for_delivery':
            cur.execute("UPDATE paket SET status=%s, kurir_id=%s WHERE id=%s",
                        (status_baru, kurir_id, pid))
        elif driver_id and status_baru in ('in_transit_gateway', 'on_transit'):
            cur.execute("UPDATE paket SET status=%s, driver_id=%s WHERE id=%s",
                        (status_baru, driver_id, pid))
        else:
            cur.execute("UPDATE paket SET status=%s WHERE id=%s", (status_baru, pid))

        mysql.connection.commit()
        add_tracking(pid, status_baru, keterangan, lokasi, session['user_id'])
        sukses += 1

    cur.close()

    if sukses:
        flash(f'✅ {sukses} paket berhasil diupdate ke status "{STATUS_LABEL.get(status_baru, (status_baru,""))[0]}".', 'success')
    if ditolak:
        flash(f'⚠️ {ditolak} paket dilewati (tidak dalam wewenang atau tidak ditemukan).', 'warning')

    return redirect(url_for('admin_dashboard'))


@app.route('/api/map-config')
def api_map_config():
    status_map = {
        'created':              {'emoji': '📦', 'bg': '#8B5CF6', 'ring': 'rgba(139,92,246,.3)',  'label': 'Paket Dibuat',                'ratio': 0.00},
        'sorting_origin':       {'emoji': '🔀', 'bg': '#8B5CF6', 'ring': 'rgba(139,92,246,.3)',  'label': 'Sortir di Cabang Asal',       'ratio': 0.05},
        'in_transit_gateway':   {'emoji': '🚚', 'bg': '#F59E0B', 'ring': 'rgba(245,158,11,.3)',  'label': 'Menuju Gateway Asal',         'ratio': 0.15},
        'gateway_origin':       {'emoji': '🏭', 'bg': '#F59E0B', 'ring': 'rgba(245,158,11,.3)',  'label': 'Di Gateway Asal',             'ratio': 0.25},
        'on_transit':           {'emoji': '🛣️', 'bg': '#E84B13', 'ring': 'rgba(232,75,19,.3)',   'label': 'Dalam Perjalanan Antar Kota', 'ratio': 0.55},
        'arrived_gateway_dest': {'emoji': '📍', 'bg': '#F59E0B', 'ring': 'rgba(245,158,11,.3)',  'label': 'Tiba di Gateway Tujuan',      'ratio': 1.00},
        'out_for_delivery':     {'emoji': '🏍️', 'bg': '#E84B13', 'ring': 'rgba(232,75,19,.3)',   'label': 'Sedang Diantar Kurir',        'ratio': 1.00},
        'delivered':            {'emoji': '✅', 'bg': '#10B981', 'ring': 'rgba(16,185,129,.3)',  'label': 'Terkirim (POD)',              'ratio': 1.00},
        'failed_delivery':      {'emoji': '❌', 'bg': '#6B7280', 'ring': 'rgba(107,114,128,.3)', 'label': 'Gagal Pengantaran',           'ratio': 1.00},
        'on_hold':              {'emoji': '⏸️', 'bg': '#F59E0B', 'ring': 'rgba(245,158,11,.3)',  'label': 'Paket Ditahan (Hold)',        'ratio': 1.00},
        'return_process':       {'emoji': '🔄', 'bg': '#E84B13', 'ring': 'rgba(232,75,19,.3)',   'label': 'Proses Retur',               'ratio': 0.80},
        'returned':             {'emoji': '↩️', 'bg': '#6B7280', 'ring': 'rgba(107,114,128,.3)', 'label': 'Dikembalikan',               'ratio': 0.00},
        'problem':              {'emoji': '⚠️', 'bg': '#EF4444', 'ring': 'rgba(239,68,68,.3)',   'label': 'Bermasalah',                 'ratio': 0.55},
    }
    return jsonify({'status_map': status_map})



@app.route('/webhook/xendit', methods=['POST'])
def xendit_webhook():
    """
    Xendit mengirim POST ke endpoint ini saat invoice dibayar.
    Verifikasi token, update status pembayaran → lunas, catat ke sistem keuangan.
    """
    token = request.headers.get('x-callback-token', '')
    if not verify_xendit_webhook(token):
        return jsonify({'error': 'Unauthorized'}), 401

    try:
        data = request.get_json(force=True)
    except Exception:
        return jsonify({'error': 'Bad JSON'}), 400

    event_type  = data.get('event', data.get('type', ''))
    invoice_id  = data.get('id', '')
    external_id = data.get('external_id', '')
    status      = data.get('status', '')         # PAID / EXPIRED / FAILED
    paid_amount = data.get('paid_amount', data.get('amount', 0))
    payment_channel = data.get('payment_channel', data.get('payment_method', ''))
    paid_at_str  = data.get('paid_at', '')

    # Konversi timestamp xendit
    xendit_paid_at = None
    if paid_at_str:
        try:
            xendit_paid_at = datetime.strptime(paid_at_str[:19], '%Y-%m-%dT%H:%M:%S')
        except Exception:
            xendit_paid_at = datetime.utcnow()

    cur = mysql.connection.cursor()

    # Cari record pembayaran berdasarkan xendit_invoice_id atau external_id
    cur.execute(
        "SELECT py.*, p.no_resi, p.pengirim_id FROM pembayaran py JOIN paket p ON py.paket_id=p.id "
        "WHERE py.xendit_invoice_id=%s OR py.xendit_external_id=%s",
        (invoice_id, external_id)
    )
    pay = cur.fetchone()

    if not pay:
        cur.close()
        return jsonify({'status': 'ignored', 'reason': 'invoice not found'}), 200

    if status == 'PAID':
        # Tentukan metode pembayaran dari xendit
        metode_map = {
            'OVO': 'transfer', 'DANA': 'transfer', 'LINKAJA': 'transfer',
            'SHOPEEPAY': 'transfer', 'CREDIT_CARD': 'credit_card',
            'QRIS': 'qris', 'BCA': 'virtual_account', 'BNI': 'virtual_account',
            'BRI': 'virtual_account', 'MANDIRI': 'virtual_account',
        }
        metode_final = metode_map.get(payment_channel.upper() if payment_channel else '', 'transfer')

        cur.execute(
            """UPDATE pembayaran
               SET status='lunas', metode=%s,
                   xendit_paid_at=%s, xendit_payment_method=%s,
                   catatan=CONCAT(IFNULL(catatan,''), ' | Dibayar via Xendit: ', %s)
               WHERE id=%s""",
            (metode_final, xendit_paid_at, payment_channel, payment_channel or 'Online', pay['id'])
        )
        mysql.connection.commit()

        # Catat ke riwayat tracking paket
        add_tracking(
            pay['paket_id'], pay['status'] if pay.get('status') else 'created',
            f'Pembayaran diterima via {payment_channel or "Online"} (Xendit) — Rp{int(paid_amount):,}',
            'Online Payment', None
        )

    elif status in ('EXPIRED', 'FAILED'):
        cur.execute(
            "UPDATE pembayaran SET status='batal', catatan=CONCAT(IFNULL(catatan,''), ' | Xendit: ', %s) WHERE id=%s",
            (status, pay['id'])
        )
        mysql.connection.commit()

    cur.close()
    return jsonify({'status': 'ok'}), 200



@app.route('/api/xendit/create-invoice/<int:pay_id>', methods=['POST'])
@role_required('admin_cabang')
def api_xendit_create_invoice(pay_id):
    """Buat ulang / buat invoice Xendit untuk pembayaran yang sudah ada."""
    cur = mysql.connection.cursor()
    cur.execute(
        """SELECT py.*, p.no_resi, p.total_biaya, u.nama AS pengirim_nama
           FROM pembayaran py JOIN paket p ON py.paket_id=p.id JOIN users u ON p.pengirim_id=u.id
           WHERE py.id=%s""", (pay_id,)
    )
    pay = cur.fetchone()
    if not pay or pay['status'] == 'lunas':
        cur.close()
        return jsonify({'error': 'Tidak bisa buat invoice untuk pembayaran ini.'}), 400

    try:
        xinv = create_xendit_invoice(
            pay['paket_id'], pay['no_resi'], pay['jumlah'],
            pay['pengirim_nama']
        )
        cur.execute(
            """UPDATE pembayaran SET metode='transfer', xendit_invoice_id=%s,
               xendit_invoice_url=%s, xendit_external_id=%s WHERE id=%s""",
            (xinv['invoice_id'], xinv['invoice_url'], xinv['external_id'], pay_id)
        )
        mysql.connection.commit()
        cur.close()
        return jsonify({'invoice_url': xinv['invoice_url'], 'invoice_id': xinv['invoice_id']})
    except Exception as e:
        cur.close()
        return jsonify({'error': str(e)}), 500



@app.route('/payment/success')
def payment_success():
    resi = request.args.get('resi', '')
    return render_template('payment_result.html',
        success=True, resi=resi,
        message='Pembayaran berhasil! Paket Anda sedang diproses.'
    )

@app.route('/payment/failure')
def payment_failure():
    resi = request.args.get('resi', '')
    return render_template('payment_result.html',
        success=False, resi=resi,
        message='Pembayaran gagal atau dibatalkan. Silakan coba lagi.'
    )



@app.route('/api/xendit/invoice-info/<int:pay_id>')
@role_required('admin_cabang')
def api_xendit_invoice_info(pay_id):
    cur = mysql.connection.cursor()
    cur.execute("SELECT xendit_invoice_url, xendit_invoice_id, status, metode FROM pembayaran WHERE id=%s", (pay_id,))
    pay = cur.fetchone()
    cur.close()
    if not pay:
        return jsonify({'error': 'Not found'}), 404
    return jsonify(pay)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)