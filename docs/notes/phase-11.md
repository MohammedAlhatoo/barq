# المرحلة 11 · الإشعارات الفورية (FCM)

## شو اللي انعمل؟
بالمرحلة 8 شلنا Firebase لأنه ما كان في إشعارات فورية. هلأ لوحة مسار صار فيها «مختبر الإشعارات»، والإشعارات مفعّلة لمشروعنا، فرجّعنا الكود وحسّناه.

## الملفات
| الملف | شو بيعمل |
|---|---|
| `packages/barq_core/lib/src/push/push_service.dart` | كل شغل Firebase بمكان واحد: التشغيل، الإذن، التوكن، الضغط على الإشعار، والإشعار والتطبيق مفتوح |
| `packages/barq_core/lib/src/push/push_message.dart` | شكل بسيط للإشعار (عنوان، نص، بيانات) |
| `apps/*/lib/app/main_shell.dart` | بيشغّل `PushService` بعد الدخول بس |
| `apps/*/lib/app/app.dart` | لما ينضغط إشعار، بيفتح الطلب حسب `order_id` |
| `apps/customer/.../account_repository.dart` و `apps/driver/.../auth_repository.dart` | بيحذفوا التوكن قبل الخروج |
| `apps/*/android/settings.gradle.kts` و `app/build.gradle.kts` | إضافة `google-services` اللي بتقرأ `google-services.json` |
| `apps/*/android/app/src/main/AndroidManifest.xml` | `firebase_messaging_installation_id_enabled = true`: بدونه `register()` بيرفض يعطي توكن (`API disabled`) |
| `apps/*/android/gradle.properties` | `kotlin.incremental=false`: المشروع على `D:` ومكتبات Flutter على `C:`، فـ Kotlin ما بيقدر يسكّر ملفاته المؤقتة على Windows والبناء بيفشل |
| `apps/customer/.../offer_cubit.dart` | الـ API الجديد (config v7): `409 offer_changed` لما السعر يتغيّر بعد ما شافه الزبون، فبنعرض العرض الجديد وبنطلب موافقة جديدة بمفتاح جديد |

## كيف بتمشي البيانات؟
1. المستخدم بيسجّل دخول ← `MainShell` بينادي `push.init()` ثم `push.registerToken()`.
2. Firebase بيعطينا توكن ← بنبعته `PUT /me/fcm-token` (السائق: `/driver/me/fcm-token`). وإذا Firebase غيّره، `onRegistered` بيبعته من جديد.
3. صار حدث (تغيّر حالة طلب، رسالة جماعية...) ← مسار بيبعت الإشعار لـ Firebase ← بيوصل للموبايل.
4. المستخدم ضغط عليه ← بنبعت `POST /notifications/{id}/opened` (بتظهر «فُتح» باللوحة) ← التطبيق بيفتح الطلب.
5. التطبيق مفتوح ← الموبايل ما بيعرض الإشعار ← بنحدّث نقطة الإشعارات عند الزبون.
6. تسجيل خروج ← `PUT .../fcm-token` بـ `{"token": null}` **قبل** `logout`، لأنه بعد الخروج التوكن ما بيعود يشتغل.

## ليش هيك؟
- **بدون `google-services.json` التطبيق بيضل يشتغل:** `init()` بيفشل بهدوء، وإضافة Gradle بتشتغل بس إذا الملف موجود. فأي واحد بالفريق بيقدر يبني التطبيق حتى لو ما عنده الملف.
- **القائمة داخل التطبيق ضلت:** الـ push مش مضمون يوصل، فشاشة الإشعارات هي المصدر الأكيد.
- **ما استخدمنا `firebase_options.dart`:** على Android، `Firebase.initializeApp()` بيقرأ الإعدادات من `google-services.json` لحاله.

## شو لازم الفريق يعمل؟
1. بـ Firebase: ضيفوا تطبيقين بالأسماء `com.barq.barq_customer` و `com.barq.barq_driver` بالضبط.
2. نزّلوا `google-services.json` لكل واحد وحطوه بـ `apps/customer/android/app/` و `apps/driver/android/app/`.
3. مفتاح الخدمة (service account) بيترفع على لوحة مسار بس، وممنوع يدخل الريبو.
4. جرّبوا من «مختبر الإشعارات» على جهاز حقيقي: والتطبيق مفتوح، وبالخلفية، ومسكّر.

## أسئلة لازم تعرفوا جوابها
1. ليش بنحذف التوكن **قبل** طلب `logout` مش بعده؟
2. شو الفرق بين `google-services.json` ومفتاح الخدمة، ووين بيروح كل واحد؟
3. شو بيصير إذا شغّلنا التطبيق بدون `google-services.json`؟
4. ليش لازم نتعامل مع الإشعار لحالنا لما التطبيق مفتوح؟
5. ليش ما شلنا شاشة الإشعارات بعد ما صار في push؟
