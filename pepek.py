from selenium import webdriver
from selenium.webdriver.chrome.options import Options

# Konfigurasi opsi Chrome untuk mode headless
chrome_options = Options()
chrome_options.add_argument("--headless")
chrome_options.add_argument("--disable-gpu")
chrome_options.add_argument("--no-sandbox")
chrome_options.add_argument("--disable-dev-shm-usage")
chrome_options.add_argument("--single-process")  # Mengurangi penggunaan memori

# Inisialisasi WebDriver
driver = webdriver.Chrome(options=chrome_options)

# Daftar URL yang akan dibuka
urls = [
    "https://www.google.com",
    "https://www.github.com",
    "https://www.python.org",
    "https://www.stackoverflow.com"
]

# Buka setiap URL satu per satu
for url in urls:
    driver.get(url)
    print(f"Judul halaman: {driver.title}")

# Tutup browser setelah selesai
driver.quit()
