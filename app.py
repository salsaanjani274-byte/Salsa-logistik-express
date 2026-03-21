from flask import Flask, render_template, redirect, url_for, request, session, flash, jsonify
from flask_mysqldb import MySQL
from functools import wraps
import random
import string
from datetime import datetime
import os

app = Flask(__name__)
app.secret_key = 'logistik_secret_key_SALSA-ANJANI'

app.config['MYSQL_HOST'] = 'localhost'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = ''          
app.config['MYSQL_DB'] = 'db_logistik'
app.config['MYSQL_CURSORCLASS'] = 'DictCursor'

mysql = MySQL(app)

def generate_resi(kode_cabang='JKT'):
    timestamp = datetime.now().strftime('%y%m%d%H%M')
    random_part = ''.join(random.choices(string.digits, k=4))
    return f"LGS{kode_cabang}{timestamp}{random_part}"

def hash_password(password):
    return password  # plain text, tanpa hash

def check_password(password, hashed):
    return password == hashed  # langsung bandingkan

def hitung_biaya(berat_kg, harga_per_kg, nilai_barang=0):
    biaya_kirim = berat_kg * harga_per_kg
    biaya_asuransi = nilai_barang * 0.002 if nilai_barang > 0 else 0
    return round(biaya_kirim, 2), round(biaya_asuransi, 2), round(biaya_kirim + biaya_asuransi, 2)

def cek_keterlambatan(paket):
    """
    Hitung status keterlambatan sebuah paket.
    Mengembalikan dict dengan key:
      - terlambat (bool)
      - hari_estimasi (int)
      - hari_berjalan (int)
      - selisih_hari (int, positif = terlambat)
      - estimasi_tiba (date)
      - label (str)
      - warna (str)  -- 'danger' | 'warning' | 'success' | 'info'
    """
    from datetime import timedelta
    status_selesai = ('delivered', 'returned')

    if paket['status'] in status_selesai:
        return {
            'terlambat': False, 'hari_estimasi': 0, 'hari_berjalan': 0,
            'selisih_hari': 0, 'estimasi_tiba': None,
            'label': 'Selesai', 'warna': 'success'
        }

    created = paket.get('created_at')
    hari_estimasi = int(paket.get('estimasi_hari', 0) or 0)

    if not created or hari_estimasi == 0:
        return {
            'terlambat': False, 'hari_estimasi': 0, 'hari_berjalan': 0,
            'selisih_hari': 0, 'estimasi_tiba': None,
            'label': '-', 'warna': 'secondary'
        }

    # Tanggal perkiraan tiba = created + estimasi_hari kerja
    estimasi_tiba = created.date() + timedelta(days=hari_estimasi)
    hari_berjalan = (datetime.now().date() - created.date()).days
    selisih = hari_berjalan - hari_estimasi

    if selisih > 0:
        return {
            'terlambat': True,
            'hari_estimasi': hari_estimasi,
            'hari_berjalan': hari_berjalan,
            'selisih_hari': selisih,
            'estimasi_tiba': estimasi_tiba,
            'label': f'Terlambat {selisih} hari',
            'warna': 'danger'
        }
    elif selisih == 0:
        return {
            'terlambat': False,
            'hari_estimasi': hari_estimasi,
            'hari_berjalan': hari_berjalan,
            'selisih_hari': 0,
            'estimasi_tiba': estimasi_tiba,
            'label': 'Jatuh tempo hari ini',
            'warna': 'warning'
        }
    else:
        sisa = abs(selisih)
        return {
            'terlambat': False,
            'hari_estimasi': hari_estimasi,
            'hari_berjalan': hari_berjalan,
            'selisih_hari': selisih,
            'estimasi_tiba': estimasi_tiba,
            'label': f'Sisa {sisa} hari',
            'warna': 'info' if sisa <= 1 else 'success'
        }


app.jinja_env.globals['cek_keterlambatan'] = cek_keterlambatan


def add_notif(user_id, judul, pesan):
    cur = mysql.connection.cursor()
    cur.execute("INSERT INTO notifikasi (user_id, judul, pesan) VALUES (%s, %s, %s)", (user_id, judul, pesan))
    mysql.connection.commit()
    cur.close()

def add_tracking(paket_id, status, keterangan, lokasi, user_id):
    cur = mysql.connection.cursor()
    cur.execute("""
        INSERT INTO riwayat_status (paket_id, status, keterangan, lokasi, user_id)
        VALUES (%s, %s, %s, %s, %s)
    """, (paket_id, status, keterangan, lokasi, user_id))
    mysql.connection.commit()
    cur.close()

STATUS_LABEL = {
    'created': ('Paket Dibuat', 'primary'),
    'sorting_origin': ('Sorting Cabang Asal', 'warning'),
    'in_transit_gateway': ('Dikirim ke Gateway', 'info'),
    'gateway_processing': ('Proses di Gateway', 'info'),
    'on_transit': ('Dalam Perjalanan', 'warning'),
    'arrived_destination': ('Tiba di Cabang Tujuan', 'success'),
    'out_for_delivery': ('Sedang Diantar', 'primary'),
    'delivered': ('Terkirim (POD)', 'success'),
    'returned': ('Dikembalikan', 'danger'),
    'problem': ('Bermasalah', 'danger'),
}

app.jinja_env.globals['STATUS_LABEL'] = STATUS_LABEL

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
    return redirect(url_for('login'))

@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'user_id' in session:
        return redirect(url_for('dashboard_redirect'))
    if request.method == 'POST':
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '')
        cur = mysql.connection.cursor()
        cur.execute("SELECT * FROM users WHERE email=%s AND status='aktif'", (email,))
        user = cur.fetchone()
        cur.close()
        if user and check_password(password, user['password']):
            session['user_id'] = user['id']
            session['nama'] = user['nama']
            session['role'] = user['role']
            session['cabang_id'] = user['cabang_id']
            flash(f'Selamat datang, {user["nama"]}!', 'success')
            return redirect(url_for('dashboard_redirect'))
        flash('Email atau password salah.', 'danger')
    return render_template('auth/login.html')

@app.route('/register', methods=['GET', 'POST'])
def register():
    if 'user_id' in session:
        return redirect(url_for('dashboard_redirect'))
    if request.method == 'POST':
        nama = request.form.get('nama', '').strip()
        email = request.form.get('email', '').strip()
        password = request.form.get('password', '')
        no_hp = request.form.get('no_hp', '').strip()
        alamat = request.form.get('alamat', '').strip()
        cur = mysql.connection.cursor()
        cur.execute("SELECT id FROM users WHERE email=%s", (email,))
        if cur.fetchone():
            flash('Email sudah terdaftar.', 'danger')
            cur.close()
            return render_template('auth/register.html')
        hashed = hash_password(password)
        cur.execute("""
            INSERT INTO users (nama, email, password, role, no_hp, alamat)
            VALUES (%s, %s, %s, 'pelanggan', %s, %s)
        """, (nama, email, hashed, no_hp, alamat))
        mysql.connection.commit()
        cur.close()
        flash('Registrasi berhasil! Silakan login.', 'success')
        return redirect(url_for('login'))
    return render_template('auth/register.html')

@app.route('/logout')
def logout():
    session.clear()
    flash('Anda telah logout.', 'info')
    return redirect(url_for('login'))

@app.route('/dashboard')
@login_required
def dashboard_redirect():
    role = session.get('role')
    if role == 'pengelola':
        return redirect(url_for('pengelola_dashboard'))
    elif role == 'admin_cabang':
        return redirect(url_for('admin_dashboard'))
    elif role == 'kurir':
        return redirect(url_for('kurir_dashboard'))
    else:
        return redirect(url_for('pelanggan_dashboard'))

@app.route('/pengelola')
@role_required('pengelola')
def pengelola_dashboard():
    cur = mysql.connection.cursor()
    cur.execute("SELECT COUNT(*) as total FROM paket")
    total_paket = cur.fetchone()['total']
    cur.execute("SELECT COUNT(*) as total FROM paket WHERE status='delivered'")
    delivered = cur.fetchone()['total']
    cur.execute("SELECT COUNT(*) as total FROM paket WHERE status NOT IN ('delivered','returned')")
    on_process = cur.fetchone()['total']
    cur.execute("SELECT SUM(total_biaya) as total FROM paket")
    total_rev = cur.fetchone()['total'] or 0
    cur.execute("SELECT COUNT(*) as total FROM users WHERE role='pelanggan'")
    total_pelanggan = cur.fetchone()['total']
    cur.execute("SELECT COUNT(*) as total FROM users WHERE role='kurir'")
    total_kurir = cur.fetchone()['total']
    cur.execute("""
        SELECT p.*, u.nama as pengirim_nama, l.kode as layanan_kode,
               l.estimasi_hari
        FROM paket p JOIN users u ON p.pengirim_id=u.id
        JOIN layanan l ON p.layanan_id=l.id
        ORDER BY p.created_at DESC LIMIT 10
    """)
    pakets = cur.fetchall()

    # Hitung paket terlambat (belum delivered, sudah lewat estimasi)
    cur.execute("""
        SELECT COUNT(*) as total
        FROM paket p JOIN layanan l ON p.layanan_id=l.id
        WHERE p.status NOT IN ('delivered','returned')
          AND DATEDIFF(NOW(), p.created_at) > l.estimasi_hari
    """)
    total_terlambat = cur.fetchone()['total']

    cur.execute("SELECT * FROM cabang ORDER BY tipe DESC")
    cabangs = cur.fetchall()
    cur.execute("SELECT u.*, c.nama_cabang FROM users u LEFT JOIN cabang c ON u.cabang_id=c.id ORDER BY u.created_at DESC")
    users = cur.fetchall()
    cur.close()
    notif_count = _get_notif_count()
    return render_template('pengelola/dashboard.html',
        total_paket=total_paket, delivered=delivered,
        on_process=on_process, total_rev=total_rev,
        total_pelanggan=total_pelanggan, total_kurir=total_kurir,
        total_terlambat=total_terlambat,
        pakets=pakets, cabangs=cabangs, users=users, notif_count=notif_count)

@app.route('/pengelola/cabang/tambah', methods=['GET', 'POST'])
@role_required('pengelola')
def pengelola_tambah_cabang():
    cur = mysql.connection.cursor()

    if request.method == 'POST':
        kode_cabang = request.form['kode_cabang']
        nama_cabang = request.form['nama_cabang']
        kota = request.form['kota']
        provinsi = request.form['provinsi']
        alamat = request.form['alamat']
        no_telp = request.form['no_telp']
        tipe = request.form['tipe']
        status = request.form['status']

        try:
            cur.execute("""
                INSERT INTO cabang 
                (kode_cabang, nama_cabang, kota, provinsi, alamat, no_telp, tipe, status)
                VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
            """, (kode_cabang, nama_cabang, kota, provinsi, alamat, no_telp, tipe, status))

            mysql.connection.commit()
            flash('Cabang berhasil ditambahkan.', 'success')

            return redirect(url_for('pengelola_dashboard'))

        except Exception as e:
            mysql.connection.rollback()
            flash(f'Gagal menambahkan cabang: {str(e)}', 'danger')

    cur.close()
    return render_template('pengelola/tambah_cabang.html')

@app.route('/pengelola/users/tambah', methods=['GET', 'POST'])
@role_required('pengelola')
def pengelola_tambah_user():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM cabang WHERE status='aktif'")
    cabangs = cur.fetchall()
    if request.method == 'POST':
        nama = request.form['nama']
        email = request.form['email']
        password = request.form['password']
        role = request.form['role']
        no_hp = request.form['no_hp']
        cabang_id = request.form.get('cabang_id') or None
        hashed = hash_password(password)
        cur.execute("INSERT INTO users (nama,email,password,role,no_hp,cabang_id) VALUES (%s,%s,%s,%s,%s,%s)",
                    (nama, email, hashed, role, no_hp, cabang_id))
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
    flash('User diaktifkan kembali.', 'warning')
    return redirect(url_for('pengelola_dashboard'))

@app.route('/pengelola/laporan')
@role_required('pengelola')
def pengelola_laporan():
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT p.*, u.nama as pengirim, l.nama as layanan, cb.nama_cabang as cabang_asal
        FROM paket p JOIN users u ON p.pengirim_id=u.id
        JOIN layanan l ON p.layanan_id=l.id
        JOIN cabang cb ON p.cabang_asal_id=cb.id
        ORDER BY p.created_at DESC
    """)
    pakets = cur.fetchall()
    cur.execute("SELECT status, COUNT(*) as total FROM paket GROUP BY status")
    status_count = cur.fetchall()
    cur.close()
    notif_count = _get_notif_count()
    return render_template('pengelola/laporan.html', pakets=pakets, status_count=status_count, notif_count=notif_count)

@app.route('/pengelola/keterlambatan')
@role_required('pengelola')
def pengelola_keterlambatan():
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT p.*, u.nama as pengirim, l.nama as layanan_nama,
               l.kode as layanan_kode, l.estimasi_hari,
               cb.nama_cabang as cabang_asal,
               DATEDIFF(NOW(), p.created_at) as hari_berjalan,
               (DATEDIFF(NOW(), p.created_at) - l.estimasi_hari) as selisih_hari
        FROM paket p
        JOIN users u ON p.pengirim_id=u.id
        JOIN layanan l ON p.layanan_id=l.id
        JOIN cabang cb ON p.cabang_asal_id=cb.id
        WHERE p.status NOT IN ('delivered','returned')
          AND DATEDIFF(NOW(), p.created_at) > l.estimasi_hari
        ORDER BY selisih_hari DESC
    """)
    pakets_terlambat = cur.fetchall()
    cur.close()
    notif_count = _get_notif_count()
    return render_template('pengelola/keterlambatan.html',
        pakets_terlambat=pakets_terlambat, notif_count=notif_count)

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
    cur.execute("""
        SELECT p.*, u.nama as pengirim_nama, l.kode as layanan_kode,
               l.estimasi_hari, k.nama as kurir_nama
        FROM paket p JOIN users u ON p.pengirim_id=u.id
        JOIN layanan l ON p.layanan_id=l.id
        LEFT JOIN users k ON p.kurir_id=k.id
        WHERE p.cabang_asal_id=%s OR p.cabang_tujuan_id=%s
        ORDER BY p.created_at DESC LIMIT 20
    """, (cabang_id, cabang_id))
    pakets = cur.fetchall()

    # Hitung paket terlambat di cabang ini
    cur.execute("""
        SELECT COUNT(*) as total
        FROM paket p JOIN layanan l ON p.layanan_id=l.id
        WHERE (p.cabang_asal_id=%s OR p.cabang_tujuan_id=%s)
          AND p.status NOT IN ('delivered','returned')
          AND DATEDIFF(NOW(), p.created_at) > l.estimasi_hari
    """, (cabang_id, cabang_id))
    total_terlambat = cur.fetchone()['total']

    cur.execute("SELECT * FROM users WHERE role='kurir' AND cabang_id=%s AND status='aktif'", (cabang_id,))
    kurirs = cur.fetchall()
    cur.execute("SELECT * FROM layanan WHERE status='aktif'")
    layanans = cur.fetchall()
    cur.execute("SELECT * FROM cabang WHERE status='aktif'")
    cabangs = cur.fetchall()
    cur.close()
    notif_count = _get_notif_count()
    return render_template('admin/dashboard.html',
        cabang=cabang, total=total, delivered=delivered,
        on_delivery=on_delivery, total_terlambat=total_terlambat,
        pakets=pakets, kurirs=kurirs,
        layanans=layanans, cabangs=cabangs, notif_count=notif_count)

@app.route('/admin/paket/buat', methods=['POST'])
@role_required('admin_cabang')
def admin_buat_paket():
    return _proses_buat_paket(redirect_ke='admin_dashboard')


@app.route('/admin/tambah-pengiriman', methods=['GET', 'POST'])
@role_required('admin_cabang')
def admin_tambah_pengiriman():
    cabang_id = session['cabang_id']
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM cabang WHERE id=%s", (cabang_id,))
    cabang = cur.fetchone()
    cur.execute("SELECT * FROM layanan WHERE status='aktif'")
    layanans = cur.fetchall()
    cur.execute("SELECT * FROM cabang WHERE status='aktif'")
    cabangs = cur.fetchall()
    cur.close()

    if request.method == 'POST':
        return _proses_buat_paket(redirect_ke='admin_tambah_pengiriman')

    notif_count = _get_notif_count()
    return render_template('admin/tambah_pengiriman.html',
        cabang=cabang, layanans=layanans, cabangs=cabangs, notif_count=notif_count)


def _proses_buat_paket(redirect_ke='admin_dashboard'):
    """Helper: proses form tambah paket, dipakai oleh 2 route."""
    cabang_id = session['cabang_id']
    cur = mysql.connection.cursor()

    try:
        cur.execute("SELECT kode_cabang, kota, id FROM cabang WHERE id=%s", (cabang_id,))
        cabang = cur.fetchone()

        email_pengirim = request.form.get('email_pengirim', '').strip()
        cur.execute("SELECT * FROM users WHERE email=%s", (email_pengirim,))
        pengirim = cur.fetchone()
        if not pengirim:
            flash('❌ Email pengirim tidak ditemukan. Pastikan pelanggan sudah registrasi.', 'danger')
            cur.close()
            return redirect(url_for(redirect_ke))

        layanan_id = request.form.get('layanan_id', '')
        if not layanan_id:
            flash('❌ Pilih layanan pengiriman terlebih dahulu.', 'danger')
            cur.close()
            return redirect(url_for(redirect_ke))

        cur.execute("SELECT * FROM layanan WHERE id=%s", (layanan_id,))
        layanan = cur.fetchone()
        if not layanan:
            flash('❌ Layanan tidak valid.', 'danger')
            cur.close()
            return redirect(url_for(redirect_ke))

        berat        = float(request.form.get('berat', 0) or 0)
        p            = float(request.form.get('panjang', 0) or 0)
        l            = float(request.form.get('lebar', 0) or 0)
        t            = float(request.form.get('tinggi', 0) or 0)
        nilai_barang = float(request.form.get('nilai_barang', 0) or 0)
        jalur        = request.form.get('jalur', 'darat')

        berat_vol    = round((p * l * t) / 6000, 2) if (p and l and t) else 0
        berat_bayar  = max(berat, berat_vol)

        biaya_kirim, biaya_asuransi, total_biaya = hitung_biaya(
            berat_bayar, float(layanan['harga_per_kg']), nilai_barang)

        no_resi = generate_resi(cabang['kode_cabang'])

        kota_tujuan = request.form.get('kota_tujuan', '')
        cur.execute("SELECT id FROM cabang WHERE kota=%s LIMIT 1", (kota_tujuan,))
        cab_tujuan    = cur.fetchone()
        cab_tujuan_id = cab_tujuan['id'] if cab_tujuan else None

        cur.execute("""
            INSERT INTO paket (
                no_resi, pengirim_id, nama_penerima, no_hp_penerima, alamat_penerima,
                kota_asal, kota_tujuan, cabang_asal_id, cabang_tujuan_id, layanan_id,
                berat, panjang, lebar, tinggi, berat_volume, berat_bayar, isi_paket,
                nilai_barang, biaya_kirim, biaya_asuransi, total_biaya, jalur, status
            ) VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,'created')
        """, (
            no_resi, pengirim['id'],
            request.form.get('nama_penerima', ''),
            request.form.get('no_hp_penerima', ''),
            request.form.get('alamat_penerima', ''),
            cabang['kota'], kota_tujuan,
            cabang_id, cab_tujuan_id, layanan_id,
            berat, p, l, t, berat_vol, berat_bayar,
            request.form.get('isi_paket', ''),
            nilai_barang, biaya_kirim, biaya_asuransi, total_biaya, jalur
        ))
        paket_id = cur.lastrowid
        mysql.connection.commit()

        add_tracking(
            paket_id, 'created',
            f'Paket diterima di cabang {cabang["kota"]}. Layanan: {layanan["nama"]}',
            cabang['kota'], session['user_id']
        )
        add_notif(
            pengirim['id'],
            'Paket Berhasil Dibuat',
            f'No Resi: {no_resi} | Tujuan: {kota_tujuan} | Total: Rp{total_biaya:,.0f}'
        )
        cur.close()
        flash(f'✅ Paket berhasil dibuat! No Resi: {no_resi}', 'success')

    except Exception as e:
        cur.close()
        flash(f'❌ Terjadi kesalahan: {str(e)}', 'danger')

    return redirect(url_for(redirect_ke))

@app.route('/admin/paket/update-status/<int:paket_id>', methods=['POST'])
@role_required('admin_cabang')
def admin_update_status(paket_id):
    status = request.form['status']
    keterangan = request.form.get('keterangan', '')
    lokasi = request.form.get('lokasi', '')
    kurir_id = request.form.get('kurir_id') or None
    cur = mysql.connection.cursor()
    if kurir_id:
        cur.execute("UPDATE paket SET status=%s, kurir_id=%s WHERE id=%s", (status, kurir_id, paket_id))
    else:
        cur.execute("UPDATE paket SET status=%s WHERE id=%s", (status, paket_id))
    mysql.connection.commit()
    add_tracking(paket_id, status, keterangan, lokasi, session['user_id'])
    cur.execute("SELECT pengirim_id, no_resi FROM paket WHERE id=%s", (paket_id,))
    paket = cur.fetchone()
    label = STATUS_LABEL.get(status, (status, ''))[0]
    add_notif(paket['pengirim_id'], 'Update Status Paket', f'Resi {paket["no_resi"]} → {label}')
    cur.close()
    flash('Status paket diperbarui.', 'success')
    return redirect(url_for('admin_dashboard'))

@app.route('/kurir')
@role_required('kurir')
def kurir_dashboard():
    user_id = session['user_id']
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT p.*, u.nama as pengirim, l.kode as layanan_kode,
               l.estimasi_hari
        FROM paket p JOIN users u ON p.pengirim_id=u.id
        JOIN layanan l ON p.layanan_id=l.id
        WHERE p.kurir_id=%s ORDER BY p.updated_at DESC
    """, (user_id,))
    pakets = cur.fetchall()
    cur.execute("SELECT COUNT(*) as t FROM paket WHERE kurir_id=%s AND status='out_for_delivery'", (user_id,))
    on_delivery = cur.fetchone()['t']
    cur.execute("SELECT COUNT(*) as t FROM paket WHERE kurir_id=%s AND status='delivered'", (user_id,))
    delivered = cur.fetchone()['t']

    # Hitung paket yang terlambat untuk kurir ini
    cur.execute("""
        SELECT COUNT(*) as total
        FROM paket p JOIN layanan l ON p.layanan_id=l.id
        WHERE p.kurir_id=%s
          AND p.status NOT IN ('delivered','returned')
          AND DATEDIFF(NOW(), p.created_at) > l.estimasi_hari
    """, (user_id,))
    total_terlambat = cur.fetchone()['total']

    cur.close()
    notif_count = _get_notif_count()
    return render_template('kurir/dashboard.html',
        pakets=pakets, on_delivery=on_delivery, delivered=delivered,
        total_terlambat=total_terlambat, notif_count=notif_count)

@app.route('/kurir/pod/<int:paket_id>', methods=['POST'])
@role_required('kurir')
def kurir_pod(paket_id):
    nama_penerima = request.form['nama_penerima']
    cur = mysql.connection.cursor()
    cur.execute("""
        UPDATE paket SET status='delivered', pod_penerima=%s, pod_waktu=NOW()
        WHERE id=%s AND kurir_id=%s
    """, (nama_penerima, paket_id, session['user_id']))
    mysql.connection.commit()
    add_tracking(paket_id, 'delivered', f'Paket diterima oleh {nama_penerima}', 'Alamat Penerima', session['user_id'])
    cur.execute("SELECT pengirim_id, no_resi FROM paket WHERE id=%s", (paket_id,))
    paket = cur.fetchone()
    add_notif(paket['pengirim_id'], 'Paket Terkirim!', f'Resi {paket["no_resi"]} telah diterima oleh {nama_penerima}')
    cur.close()
    flash('POD berhasil dikonfirmasi!', 'success')
    return redirect(url_for('kurir_dashboard'))

@app.route('/pelanggan')
@role_required('pelanggan')
def pelanggan_dashboard():
    user_id = session['user_id']
    cur = mysql.connection.cursor()
    cur.execute("""
        SELECT p.*, l.nama as layanan_nama, l.kode as layanan_kode,
               l.estimasi_hari, cb.nama_cabang as cabang_asal_nama
        FROM paket p JOIN layanan l ON p.layanan_id=l.id
        JOIN cabang cb ON p.cabang_asal_id=cb.id
        WHERE p.pengirim_id=%s ORDER BY p.created_at DESC
    """, (user_id,))
    pakets = cur.fetchall()
    cur.execute("SELECT COUNT(*) as t FROM paket WHERE pengirim_id=%s", (user_id,))
    total = cur.fetchone()['t']
    cur.execute("SELECT COUNT(*) as t FROM paket WHERE pengirim_id=%s AND status='delivered'", (user_id,))
    delivered = cur.fetchone()['t']
    cur.execute("SELECT SUM(total_biaya) as s FROM paket WHERE pengirim_id=%s", (user_id,))
    total_biaya = cur.fetchone()['s'] or 0

    # Hitung paket pelanggan yang terlambat
    cur.execute("""
        SELECT COUNT(*) as total
        FROM paket p JOIN layanan l ON p.layanan_id=l.id
        WHERE p.pengirim_id=%s
          AND p.status NOT IN ('delivered','returned')
          AND DATEDIFF(NOW(), p.created_at) > l.estimasi_hari
    """, (user_id,))
    total_terlambat = cur.fetchone()['total']

    cur.close()
    notif_count = _get_notif_count()
    return render_template('pelanggan/dashboard.html',
        pakets=pakets, total=total, delivered=delivered,
        total_biaya=total_biaya, total_terlambat=total_terlambat,
        notif_count=notif_count)

@app.route('/tracking', methods=['GET', 'POST'])
def tracking():
    paket = None
    riwayat = []
    no_resi = ''
    if request.method == 'POST':
        no_resi = request.form.get('no_resi', '').strip()
        cur = mysql.connection.cursor()
        cur.execute("""
            SELECT p.*, u.nama as pengirim, l.nama as layanan_nama,
                   l.kode as layanan_kode, cb.nama_cabang as cabang_asal_nama
            FROM paket p JOIN users u ON p.pengirim_id=u.id
            JOIN layanan l ON p.layanan_id=l.id
            JOIN cabang cb ON p.cabang_asal_id=cb.id
            WHERE p.no_resi=%s
        """, (no_resi,))
        paket = cur.fetchone()
        if paket:
            cur.execute("""
                SELECT r.*, u.nama as petugas
                FROM riwayat_status r JOIN users u ON r.user_id=u.id
                WHERE r.paket_id=%s ORDER BY r.created_at ASC
            """, (paket['id'],))
            riwayat = cur.fetchall()
        cur.close()
    return render_template('tracking.html', paket=paket, riwayat=riwayat, no_resi=no_resi)

@app.route('/notifikasi')
@login_required
def notifikasi():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM notifikasi WHERE user_id=%s ORDER BY created_at DESC", (session['user_id'],))
    notifs = cur.fetchall()
    cur.execute("UPDATE notifikasi SET is_read=1 WHERE user_id=%s", (session['user_id'],))
    mysql.connection.commit()
    cur.close()
    return render_template('notifikasi.html', notifs=notifs)

@app.route('/api/cek-harga')
def api_cek_harga():
    berat = float(request.args.get('berat', 1))
    layanan_id = request.args.get('layanan_id')
    nilai = float(request.args.get('nilai', 0))
    cur = mysql.connection.cursor()
    cur.execute("SELECT * FROM layanan WHERE id=%s", (layanan_id,))
    l = cur.fetchone()
    cur.close()
    if not l:
        return jsonify({'error': 'Layanan tidak ditemukan'})
    biaya_kirim, biaya_asuransi, total = hitung_biaya(berat, float(l['harga_per_kg']), nilai)
    return jsonify({
        'biaya_kirim': biaya_kirim,
        'biaya_asuransi': biaya_asuransi,
        'total': total,
        'estimasi': l['estimasi_hari']
    })

def _get_notif_count():
    if 'user_id' not in session:
        return 0
    cur = mysql.connection.cursor()
    cur.execute("SELECT COUNT(*) as c FROM notifikasi WHERE user_id=%s AND is_read=0", (session['user_id'],))
    c = cur.fetchone()['c']
    cur.close()
    return c

if __name__ == '__main__':
    app.run(debug=True, port=5000)