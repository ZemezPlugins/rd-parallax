<h2 class="item1">Настройки скрипта</h2>

<h5>
    Скрипт поддерживает следующие опции для настройки
</h5>

<h3>
    Общие настройки
</h3>

<p>
    Общие настройки скрипта определяются в объекте options при инициализации.
</p>

<h5>blur</h5>
<dl class="inline-term">
    <dt>Тип</dt>
    <dd>Boolean</dd>
</dl>
<dl class="inline-term">
    <dt>Значение</dt>
    <dd>true, false</dd>
</dl>

<p>
    Если определен как true включает размытие изображения в случае, когда его размер слишком маленький
    для качественного отображения в секции параллакса.
</p>

<h5>direction</h5>
<dl class="inline-term">
    <dt>Тип</dt>
    <dd>String</dd>
</dl>
<dl class="inline-term">
    <dt>Значение</dt>
    <dd>inverse, normal</dd>
</dl>

<p>
    Определяет направление движения параллакса. Если определен, как normal - параллакс будет двигаться параллельно
    скроллу, если inverse - в противоположном направлении.
</p>

<h5>speed</h5>
<dl class="inline-term">
    <dt>Тип</dt>
    <dd>Number</dd>
</dl>
<dl class="inline-term">
    <dt>Значение</dt>
    <dd>0 ~ 2</dd>
</dl>

<p>
    Определяет скорость движения параллакса относительно движения скроллбара. Для большего понимания, если
    значение скорости равно 1 - получаем эмуляцию css свойства background-attachment: fixed
</p>

<h5>duration</h5>
<dl class="inline-term">
    <dt>Тип</dt>
    <dd>Number</dd>
</dl>
<dl class="inline-term">
    <dt>Значение по-умолчанию</dt>
    <dd>200</dd>
</dl>

<p>
    Время анимации движения параллакса (необходимо исключительно для мобильных устройтв)
</p>

<h5>easing</h5>
<dl class="inline-term">
    <dt>Тип</dt>
    <dd>String</dd>
</dl>
<dl class="inline-term">
    <dt>Значение по-умолчанию</dt>
    <dd>linear</dd>
</dl>

<p>
    Переменная функция анимации движения параллакса (необходимо исключительно для мобильных устройтв)
</p>

<h5>screenAliases</h5>
<dl class="inline-term">
    <dt>Тип</dt>
    <dd>Object</dd>
</dl>
<dl class="inline-term">
    <dt>Значение по-умолчанию</dt>
    <dd>{ 0: '', 480: 'xs', 768: 'sm', 992: 'md', 1200: 'lg'}</dd>
</dl>

<p>
    Объект, содержащий алиасы имен для создания адаптивных настроек слоев паралакса
</p>


<h3>
    Настройки слоев
</h3>

<p>
    Скрипт также поддерживает дополнительную настройку каждого из слоев. Настройка каждого из слоев выполняется в HTML разметке
    слоя с помощью data-атрибут API.
</p>

<h5>data-type</h5>
<dl class="inline-term">
    <dt>Тип</dt>
    <dd>String</dd>
</dl>
<dl class="inline-term">
    <dt>Значение</dt>
    <dd>media, html</dd>
</dl>

<p>
    Определяет тип слоя параллакса. Если определен как media, будет производиться расчет размера слоя относительно высоты секции
    параллакса, если html - размер определяется контентом.
</p>

<h5>data-url</h5>
<dl class="inline-term">
    <dt>Тип</dt>
    <dd>String</dd>
</dl>

<p>
    Определяет путь к изображению для отоборажения в качестве бекграунда слоя.
</p>

<h5>data-speed, data-xs-speed, data-sm-speed, data-md-speed, data-lg-speed</h5>
<dl class="inline-term">
    <dt>Тип</dt>
    <dd>Number</dd>
</dl>
<dl class="inline-term">
    <dt>Значение</dt>
    <dd>0 ~ 2</dd>
</dl>

<p>
    Определяет скорость движения параллакса относительно движения скроллбара. Для большего понимания, если
    значение скорости равно 1 - получаем эмуляцию css свойства background-attachment: fixed.
</p>

<h5>data-fade</h5>
<dl class="inline-term">
    <dt>Тип</dt>
    <dd>Boolean</dd>
</dl>
<dl class="inline-term">
    <dt>Значение</dt>
    <dd>true, false</dd>
</dl>

<p>
    Если установлен в true, слой будет постепенно проявляться из полной прозрачности в полную непрозрачность
    в зависимости от позиции скролла слоя.
</p>

<h5>data-blur</h5>
<dl class="inline-term">
    <dt>Тип</dt>
    <dd>Boolean</dd>
</dl>
<dl class="inline-term">
    <dt>Значение</dt>
    <dd>true, false</dd>
</dl>

<p>
    Если определен как true включает размытие изображения в случае, когда его размер слишком маленький
    для качественного отображения в секции параллакса.
</p>

<h5>data-direction, data-xs-direction, data-sm-direction, data-md-direction, data-lg-direction</h5>
<dl class="inline-term">
    <dt>Тип</dt>
    <dd>String</dd>
</dl>
<dl class="inline-term">
    <dt>Значение</dt>
    <dd>inverse, normal</dd>
</dl>

<p>
    Определяет направление движения параллакса. Если определен, как normal - параллакс будет двигаться параллельно
    скроллу, если inverse - в противоположном направлении.
</p>

