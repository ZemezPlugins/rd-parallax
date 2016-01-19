<h2 class="item1">Как использовать</h2>

<h5>
    Внедрение скрипта на страницу сводится к нескольким простым шагам.
</h5>

<p>
    <strong>Обратите внимание:</strong> предложенный вариант инициализации может отличаться в зависимости от продукта,
    в котором он внедряется. Информация предоставленная ниже лишь отображает принципы работы со скриптом.
</p>

<h3>
    Скачайте скрипт из Git'a
</h3>

<p>
    Для начала необходимо скачать данный скрипт из нашего публичного репозитория:
    <a href="http://products.git.devoffice.com/coding-development/rd-parallax">Кликабельно</a>
</p>


<h3>
    Добавьте необходимую разметку
</h3>

<p>
    HTML разметка по умолчанию для создания параллакса выглядит следующим образом.
</p>

<code>
<pre>
&lt;!-- RD Parallax --&gt;
&lt;section class="rd-parallax"&gt;
  &lt;div class="rd-parallax-layer" data-speed="0.2" data-type="media" data-url="path/to/your-image.jpg"&gt;&lt;/div&gt;
  &lt;div class="rd-parallax-layer" data-speed="0.3" data-type="html" data-fade="true"&gt;
    ...
  &lt;/div&gt;
&lt;/section&gt;
&lt;!-- END RD Parallax--&gt;
</pre>
</code>

<p>
    <strong>Обратите внимание:</strong> блок с дата атрибутом data-type="media" может содержать любой кастомный
    контент, например различные скрипты слайдеров, бекграунд видео и т.д. Для того, чтобы разместить кастомный
    контент внутри медиа объекта, просто не указывайте дата атрибут data-url.
</p>


<h3>
    Подключите стили
</h3>

<p>
    Подключите файл стилей rd-parallax.css в секции &lt;head/&gt; целевой страницы.
</p>

<code>
<pre>
&lt;link rel="stylesheet" href="path/to/css/rd-parallax.css"&gt;
</pre>
</code>

<h3>
    Подключите скрипт на странице
</h3>

<p>
    Вам необходимо скоппировать скрипт в папку /js вашего проекта и выполнить его подключение на странице. Для это можно
    исспользовать следующий участок кода:
</p>

<code>
<pre>
&lt;script src="js/rd-parallax.min.js"&gt;&lt;/script&gt;
</pre>
</code>


<h3>
    Выполните инициализацию скрипта
</h3>

<p>
    Вам необходимо выполнить инициализацию скрипта для элементов по целевому селектору, с помощью следующего участка кода
</p>

<code>
<pre>
&lt;script&gt;
  $(document).ready(function () {
    $.RDParallax({}); // Additional options
  });
&lt;/script&gt;
</pre>
</code>

