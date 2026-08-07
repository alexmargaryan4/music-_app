# MusicApp — Flutter

Приложение для поиска музыки на базе публичного iTunes Search API, с AI-ассистентом
для рекомендаций на базе Groq.

Готовые конфиги в этом репозитории:
- **Android**: `AndroidManifest.xml` (разрешение `INTERNET`), `build.gradle`, иконки (обычные + adaptive)
- **iOS**: `Info.plist`, `Podfile`, Xcode-проект настроен на сборку без подписи
- **GitHub Actions** (`.github/workflows/build.yml`): job для Android APK (подписан debug-ключом) и job для unsigned iOS IPA

---

## 1. Куда вставить свой Groq-ключ

Ключ **не хардкодится в коде**. Он передаётся при сборке через `--dart-define=GROQ_API_KEY=...`
и читается в `lib/services/groq_service.dart`:

```dart
static const String apiKey = String.fromEnvironment(
  'GROQ_API_KEY',
  defaultValue: 'REPLACE_WITH_YOUR_GROQ_API_KEY',
);
```

Получить бесплатный ключ: https://console.groq.com/keys

### Вариант A — сборка в GitHub Actions (рекомендуется)

1. Зайдите в свой репозиторий на GitHub → **Settings → Secrets and variables → Actions**.
2. Нажмите **New repository secret**.
3. Имя: `GROQ_API_KEY`, значение — ваш ключ из Groq. Сохраните.
4. Всё — workflow сам подставит его при следующей сборке (`.github/workflows/build.yml`
   уже читает `secrets.GROQ_API_KEY`).

Если секрет не задан, сборка всё равно пройдёт, но AI-чат в приложении не будет
работать (будет использован placeholder-ключ).

### Вариант B — локальная сборка на своей машине

```bash
flutter build apk --release --dart-define=GROQ_API_KEY=ваш_ключ_здесь
flutter build ios --release --no-codesign --dart-define=GROQ_API_KEY=ваш_ключ_здесь
```

При `flutter run` для разработки:

```bash
flutter run --dart-define=GROQ_API_KEY=ваш_ключ_здесь
```

> **Важно про безопасность.** В этом проекте нет отдельного бэкенда — ключ Groq
> зашивается прямо в собранный APK/IPA при компиляции. Любой, кто разберёт
> сборку, потенциально может его извлечь. Для реального публичного продакшена
> обычно ключ прячут за собственным сервером-прокси. Для личного/тестового
> использования текущая схема — нормальный компромисс, но не публикуйте такой
> APK/IPA широко без понимания этого риска, и будьте готовы перевыпустить ключ
> в Groq, если заметите злоупотребление.

---

## 2. Как задеплоить репозиторий на GitHub

**Важно:** в скачанном архиве папка `MusicApp` содержит две вещи рядом —
`.github` (конфиг сборки) и `musicapp_flutter` (сам проект). При заливке на
GitHub обе папки должны попасть в **корень репозитория** — то есть содержимое
именно `MusicApp`, а не только `musicapp_flutter`. Иначе GitHub Actions не
увидит workflow.

1. Создайте пустой репозиторий на GitHub (без README/gitignore, чтобы не было
   конфликтов) — кнопка **New repository** на github.com.
2. В папке `MusicApp` (та, что содержит `.github` и `musicapp_flutter` рядом
   друг с другом) на своём компьютере:

```bash
cd MusicApp
git init
git add .
git commit -m "Initial commit: MusicApp Flutter"
git branch -M main
git remote add origin https://github.com/ВАШ_ЛОГИН/ВАШ_РЕПОЗИТОРИЙ.git
git push -u origin main
```

После пуша в репозитории на GitHub в корне должны быть видны сразу обе папки:
`.github` и `musicapp_flutter`. Если заливаете через веб-интерфейс GitHub
(перетаскиванием файлов) — точно так же перетащите обе папки одновременно,
не заходя внутрь `musicapp_flutter`.

3. Добавьте секрет `GROQ_API_KEY`, как описано в разделе 1.
4. Откройте вкладку **Actions** в репозитории — сборка запустится автоматически
   при пуше в `main` (или запустите вручную кнопкой **Run workflow**, она видна
   благодаря `workflow_dispatch` в конфиге).

---

## 3. Как скачать артефакты сборки

1. В репозитории на GitHub откройте вкладку **Actions**.
2. Выберите последний прогон workflow **Build MusicApp** (зелёная галочка — успех).
3. Прокрутите вниз до раздела **Artifacts**. Там будет два файла:
   - `musicapp-android-apk` — архив с `app-release.apk`
   - `musicapp-ios-unsigned-ipa` — архив с `MusicApp-unsigned.ipa`
4. Кликните на нужный — скачается zip-архив, внутри лежит сам файл (`.apk` или `.ipa`).

Артефакты хранятся 30 дней (настроено в workflow через `retention-days: 30`),
после — удаляются автоматически, пересоберите заново при необходимости.

**Android APK** можно установить сразу — он подписан debug-ключом Flutter,
достаточно разрешить установку из неизвестных источников на телефоне.

**iOS IPA** — не подписан и сам по себе не установится на устройство. Нужно
подписать его самостоятельно (см. следующий раздел).

---

## 4. Как подписать unsigned IPA через ESign

[ESign](https://github.com/EskeetzTv/ESign) (или его форки/аналоги вроде AltStore,
Sideloadly, Feather) — позволяет подписать `.ipa` бесплатным Apple ID и установить
на устройство без публикации в App Store.

Общий процесс (детали интерфейса могут отличаться в зависимости от версии ESign):

1. Скачайте и установите ESign (обычно устанавливается через сам ESign/AltStore-подобный
   механизм, либо собирается из исходников — следуйте актуальной инструкции в репозитории
   выбранного инструмента, т.к. процесс регулярно меняется из-за политики Apple).
2. Скачайте `MusicApp-unsigned.ipa` из артефактов GitHub Actions (раздел 3) на iPhone/iPad
   или на компьютер, с которого будете передавать файл на устройство.
3. Откройте ESign, добавьте файл `MusicApp-unsigned.ipa` (обычно через раздел
   "Import"/"+" на главном экране).
4. Выберите **Signing Certificate** — свой бесплатный Apple ID (ESign сам предложит
   войти и создать сертификат разработки) или платный Developer-аккаунт, если есть.
5. Нажмите **Sign** (Подписать). После завершения — **Install** (Установить)
   на подключённое или текущее устройство.
6. На iPhone: **Настройки → Основные → VPN и управление устройством** — подтвердите
   доверие профилю разработчика, которым подписано приложение (обычно это ваш Apple ID
   или сертификат ESign).
7. Запустите MusicApp с домашнего экрана.

**Важные ограничения бесплатного Apple ID:**
- Приложение, подписанное бесплатным аккаунтом, работает **7 дней**, затем нужно
  переподписать заново (тот же `.ipa` можно подписывать повторно).
- Максимум **3 таких приложения** одновременно на бесплатном аккаунте (лимит Apple
  на количество App ID в неделю).
- Платный Apple Developer Program (99$/год) снимает 7-дневное ограничение —
  приложение будет работать полный год до истечения сертификата.

---

## 5. Структура проекта

```
lib/
  main.dart
  models/     — Track, Playlist, ChatMessage, UserProfile и т.д. (+ Hive-адаптеры *.g.dart)
  services/   — ITunesService, GroqService, LyricsService, репозитории (Hive-хранилище)
  state/      — Provider-провайдеры (Library, Player, Search, Chat, Settings)
  theme/      — цветовая палитра и тема приложения
  widgets/    — переиспользуемые виджеты (карточки треков, мини-плеер и т.д.)
  screens/    — экраны приложения
  l10n/       — строки интерфейса (ru/en/hy)
android/      — нативный Android-проект (Gradle)
ios/          — нативный iOS-проект (Xcode)
.github/workflows/build.yml — CI: Android APK + unsigned iOS IPA
```

---

## 6. Локальная сборка (если у вас уже установлен Flutter)

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs   # генерация Hive-адаптеров
flutter analyze
flutter build apk --release --dart-define=GROQ_API_KEY=ваш_ключ
```

Для iOS сборка возможна только на macOS с установленным Xcode и CocoaPods:

```bash
cd ios && pod install && cd ..
flutter build ios --release --no-codesign --dart-define=GROQ_API_KEY=ваш_ключ
```

---

## 7. API, которые использует приложение

- **iTunes Search API** — `https://itunes.apple.com/search` — публичный, без ключа
  (`lib/services/itunes_service.dart`).
- **Groq API** (`https://api.groq.com/openai/v1/chat/completions`, модель
  `llama-3.3-70b-versatile`) — для AI-рекомендаций музыки, нужен свой ключ
  (`lib/services/groq_service.dart`).
- **LRCLIB** — для синхронизированных текстов песен (`lib/services/lyrics_service.dart`).

Все запросы идут напрямую с телефона — отдельного backend-сервера в этой версии
проекта нет.
