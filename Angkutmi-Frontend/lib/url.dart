// jika ingin debug di chrome/edge
// 1. ubah baseUrl di bawah ini menjadi 127.0.0.0
// 2. navigasi ke folder backend menggunakan terminal
// 3. nyalakan backend dengan "php artisan ser"

// jika ingin debug di handphone external menggunakan usb-c (direkomendasikan)
// 1. pastikan hotspot handphone external terubung dengan device pengembangan
// 2. ketik ipconfig di terminal
// 3. dalam "Wireless LAN adapter Wi-Fi", cari IPv4 address
// 4. copy nomor tersebut dan paste di variabel bawah ini
// 5. navigasi ke folder backend menggunakan terminal
// 6. nyalakan backend dengan "php artisan ser --host={IPv4 address} --port=8080"

const String baseUrl =
'http://192.168.251.1:8080';

// EXTRA NOTE:
// entah kenapa url di api_langganan.dart (fetching fitur "nantipi") tidak bisa di tarik dari sini
// jadi plis ubah variabel "apiUrl" yang terdapat di "lib\service\api_langganan.dart" 😭

// const String apiUrl = baseUrl;

// ^bahkan ini juga sudah di coba tidak bisa 💀

// semoga dengan ini kami bisa menjadi developer yang lebih baik lagi yaTuhan, amin

// best regards,
// Aryo from the frontend team and by extension, the Angkutmi Team.