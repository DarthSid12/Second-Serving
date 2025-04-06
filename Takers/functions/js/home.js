function toggleQRCode() {
    const qr = document.getElementById('qr-code');
    if (qr.style.display === 'none') {
      qr.style.display = 'block';
      qr.innerHTML = '<img src="QRCode.jpeg" alt="QR Code" style="width:100%; height:100%;">';
    } else {
      qr.style.display = 'none';
      qr.innerHTML = '';
    }
  }
  