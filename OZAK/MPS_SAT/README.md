# MPS_SAT

Hedef kaynak (lokal): `C:\Users\yonetim1\Desktop\OZAK\MPS_SAT\MPS_SAT.xml`

Cloud/repo kopyas? bu klas?re konacak. Dosya hen?z y?klenmedi.

## Senkron (lokal PowerShell)

```powershell
cd "...\Mozan1"
New-Item -ItemType Directory -Force -Path .\OZAK\MPS_SAT | Out-Null
Copy-Item "C:\Users\yonetim1\Desktop\OZAK\MPS_SAT\*" .\OZAK\MPS_SAT\ -Force
git add OZAK/MPS_SAT
git commit -m "Add MPS_SAT makro package"
git push
```

veya `MPS_SAT.xml` dosyas?n? sohbete Attach edin.
