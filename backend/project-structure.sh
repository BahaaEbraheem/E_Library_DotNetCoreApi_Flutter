# إنشاء هيكل المشروع
mkdir -p E_Library/{backend,frontend}

# نقل ملفات Backend
cp -r E_Library.API/* E_Library/backend/

# نقل ملفات Flutter
cp -r flutter_project/* E_Library/frontend/