# ViraKran
Приложение для строительной компании, занимающейся сдачей в аренду тяжелой строительной техники (башенные и быстромонтируемые краны, автокраны, строительные подъемники). Разработано для ОС iOS от 11 версии и новее.

У приложения есть авторизация, реализованной с помощью Firebase.

Неавторизованный пользователь может: просматривать каталог с техникой компании (отсортировав его по своему желанию), просматривать отзывы к выбранной технике из каталога от авторизованных пользователей, просматривать новости компании на главном экране.
Если его что-то заинтересовало, он может связаться с компанией с помощью мобильной связи (выполняется переход в Телефон).

Авторизованному пользователю доступно все тоже, что и неавторизованному пользователю. При этом он может самостоятельно оставлять отзывы к технике, добавлять/удалять технику в Избранное, может связаться с представителем компании в чате, где может отправить как текстовое сообщение, так и изображение.
Он может установить изображение своему профилю, с помощью Камеры или Галерии (запрашиваются разрешения для доступа и к Камере, и к Галерее), и выбрать отображемую валюту для цены за аренду техники. Данные валют ежедневно берутся с ЦБ РФ.

У представителя компании немного отличная версия приложения. Его главная задача консультация пользователей при выборе техники через чаты. Поэтому для него реализована отдельная версия раздела с чатами в приложении.
Остальные функции приложения для него не отличаются от тех, которые доступны обычному пользователю.

Для регистрации в приложении, надо принять соглашение с политикой о конфидициальности (составлено примерно), а также подтвердить регистрацию через почту, куда придет ссылка для подтверждения (реализовано с помощью Firebase). Пользователь может со временем сменить пароль, сбросив его.

Данные пользователей (кроме паролей), данные с техникой и новостями компании хранятся в Firestore Database в виде коллекций с документами. Изображения из чатов, профилей пользователей и техники компании хранятся в Storage (Firebase). Для защиты от нежелательных запросов были прописаны соответсвующие правила в разделе Rules в Firebase.

В качестве вспомогательных средств в проекте используются: FirebaseAnalytics, FirebaseAuth, FirebaseFirestore, FirebaseStorage – библиотеки для работы с Firebase; RealmSwift – библиотека для взаимодействия с базой данных Realm; MessageKit – библиотека для реализации интерфейса чатов; SDWebImage – библиотека для загрузки изображений; JJFloatingActionButton – библиотека для реализации элемента интерфейса плавающая кнопка; JGProgressHUD – библиотека для реализации индикатора прогресса; API курсов валют ЦБ РФ.
