# ابدأ هنا — مشروع برق

المشروع بينبني بـ **Claude Code واحد**، مرحلة مرحلة، والفريق كله بيراجع ويناقش ويفهم كل مرحلة.

## الملفات
| الملف | لشو |
|---|---|
| `docs/PLAN.md` | **ترتيب البناء** (المراحل 0–8) + أدوار الفريق بالمراجعة |
| `docs/notes/phase-N.md` | شرح كل مرحلة بالعربي (Claude بيكتبه بآخر كل مرحلة) |
| `docs/tasks/01…04` | مواصفات كل جزء: الشاشات، الصور، الـ API، الملاحظات |
| `docs/design/screens/*.png` | شكل كل شاشة بالضبط |
| `docs/design/html/*.html` | التصميم ككود: النصوص والأرقام الدقيقة (افتحه بالمتصفح) |
| `packages/barq_ui/README.md` | المكونات الجاهزة + جدول "بالتصميم ← بالكود" |
| `docs/ARCHITECTURE.md` | بنية المشروع + أسماء `barq_core` الثابتة |
| `docs/api/API_NOTES.md` | قواعد الـ API + التصحيحات على خطة الـ PDF |
| `AGENTS.md` / `CLAUDE.md` | قواعد Claude Code بالمشروع |

## دورة كل مرحلة
1. صاحب Claude Code بيعمل فرع المرحلة (`phase-N-…`) وبيقول لـ Claude: «نفّذ المرحلة N من docs/PLAN.md».
2. Claude بيبني، بيشغّل، بيقارن مع التصميم، وبيكتب `docs/notes/phase-N.md`.
3. Push + Pull Request على `dev`.
4. **اجتماع المراجعة:** كل واحد بيعمل `git pull` وبيشغّل التطبيق، بيقرأوا الشرح، وبيناقشوا. أي سؤال بينسأل لـ Claude: «اشرح ليش عملت كذا بـ [الملف]».
5. التعديلات المطلوبة بتتعمل بنفس الفرع، وبعدين الدمج على `dev`.

## لكل الفريق: كيف تشغّل المشروع عندك
1. Android Studio ← **File ← New ← Project from Version Control** ← رابط الـ repo ← Clone.
2. بدّل لفرع `dev` (اسم الفرع تحت على اليمين ← `origin/dev` ← Checkout).
3. بالـ Terminal: `cd apps/customer` ← `flutter pub get` ← وشغّل مع المفتاح:
   `flutter run --dart-define=BARQ_PROJECT_KEY=pk_test_xxx`
4. كل ما تندمج مرحلة: **Git ← Pull**.
