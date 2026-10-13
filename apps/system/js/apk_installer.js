'use strict';
const PEPInstaller = {
    init() {
        console.log('PEP OS: Dual Installer Ready');
        window.addEventListener('open-app', (e) => {
            let file = e.detail.fileName || e.detail.filename || '';
            if (file.endsWith('.webapp')) this.installWebApp(file);
            if (file.endsWith('.apk')) this.installApk(file);
        });
    },
    installWebApp(url) {
        let req = navigator.mozApps.install(url);
        req.onsuccess = () => this.banner('PEP: WebApp installed ✓');
        req.onerror = () => this.banner('WebApp failed: ' + req.error.name);
    },
    installApk(path) {
        this.banner('PEP: Installing APK... 30 sec');
        let xhr = new XMLHttpRequest({ mozSystem: true });
        xhr.open('POST', 'http://localhost:2222/install', true);
        xhr.setRequestHeader('Content-Type', 'application/json');
        xhr.onload = () => {
            if (xhr.status == 200) this.banner('PEP: APK installed ✓');
            else this.banner('APK failed');
        };
        xhr.send(JSON.stringify({ file: path }));
    },
    banner(msg) {
        let b = document.getElementById('pep-banner') || document.createElement('div');
        b.id = 'pep-banner';
        b.style.cssText = 'position:fixed;bottom:20px;left:10%;width:80%;background:#6C00FF;color:#fff;padding:15px;border-radius:12px;z-index:99999;text-align:center;';
        b.textContent = msg;
        document.body.appendChild(b);
        setTimeout(() => b.remove(), 4000);
    }
};
window.addEventListener('load', () => PEPInstaller.init());