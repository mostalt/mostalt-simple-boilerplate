# mostalt Simple Boilerplate

Базовый шаблон для проектов. Буду рад замечаниям и предложениям по улучшению сборки.

## Требования

Для работы необходимы

* [Node.js](http://nodejs.org)
* [Gulp](http://gulpjs.com/): `npm install -g gulp`
* [Bower](http://bower.io): `npm install -g bower`
* [Jscs](https://github.com/mdevils/node-jscs): `npm install jscs -g`
* [Jshint](https://github.com/jshint/jshint/): `npm install jshint -g`

Если при установке npm ругается на права доступа, то стоит прочесть
https://docs.npmjs.com/getting-started/fixing-npm-permissions

## Quickstart

Устанавлием npm зависимости
```bash
npm i
```

Собирает svg-sprite, js, css
```bash
  gulp build
```

##Скрипты, шаблоны и стили для разработки хранятся внутри папки `frontend`:

* `_svg` : хранение svg, которые после сборки сформируются в спрайт внутри `frontend/svg`
* `fonts` : шрифты, которые в последующем копируются внурь `public_html/assets/fonts` с помощью `gulp fonts`
* `img` : изображение, которые в последующем сжимаются и копируются внурь `public_html/assets/img` с помощью `gulp img`
* `jade`
    * `/blocks` : блоки и миксины для формирование статики
    * `/*` : страницы проекта

* `js`
    * `app.js` : подключение модулей
    * `scripts.min.js` : сборка всех скриптов проекта
    * `/modules` : отдельные модули
    * `/lib` : сторонние библиотеки

* `styles`
    * `/blocks` : блоки проекта
    * `/global` : базовые стили для всех проектов, настройка проекта
    * `/lib` : сторонние библиотки
    * `/mixins` : часто используемые миксины
    * `app.styl` : подкючение файлов для разработки


##Медиа контент и стили для продакшена находится в папке `public_html`:

* `assets`
    * `/fonts` : хранятся шрифты проекта
    * `/img` : хранятся изображения проекта
    * `/js`: собрка скриптов
    * `/css` : сборка стилей
    * `/svg` : svg-sprite
    * `/vendor` : в данной папке храняться скрипты, которые необходимо подключить отдельно от основной сборки скриптов, например в хедере(подключение legasy-версии svg4everybody для работы svg в IE)
* `static` : html-файлы проекта

## В проекте используется
* [posthtml-bem](https://www.npmjs.com/package/posthtml-bem)
Это упрощает разработку по БЭМ-методологии со необходимой информаций и примерами можно ознакомиться по ссылке

## Для многократного использования блоков, они создаются в виде jade-миксинов

```jade
mixin testblock(params)
  div(block='test')
    div(elem='rabbit' mods=''+(params != null && params.type != null?params.type:''))
```
Которые в последующем инклюдятся в нужных файлах(страницах) и вызываются с нужными парамметрами(модификаторами)

```jade
include ../blocks/test
+testblock({type:'mobile'})
+testblock()
+testblock({type:'desktop'})
```


## Создание страниц:
В папке `frontend/jade/blocks` храниться файл `template`, который используеться для создания новых страниц, т.e. для создания новых страниц нам нужно его заэкстендить и переопредить block content

```jade
extends ../blocks/template
block content
  main(block="page-content")
```

## Спрайты

В проекте используется svg-sprite, который лежит внури `public_html/assets/svg/svg-sprite.svg`

Вызов элемента спрайта:
```jade
svg
  use(xlink:href="/assets/svg/sprite.svg#example)
```

Стили иконок спрайта храняться в `frontend/styles/global/sprite.styl`
Пример лежит `frontend/sprite.symbol.html`

## Как собираются и используются PNG спрайты

В шаблоне предусмотрена сборка нескольких PNG спрайтов и их данных в CSS переменные.

### Добавление PNG иконок

Для создания спрайта нужно добавить папку в `app/sprites` и в неё PNG иконки. Важно, чтобы иконки были с чётными высотой и шириной кратными двум. Retina иконки добавлять в эту папку рядом с обычными и в конце названия файла добавить `@2x`, например:
```
└── frontend/
    └── sprites/
        └── emoji/
            ├── grinning.png
            ├── grinning@2x.png
            ├── joy.png
            ├── joy@2x.png
            ├── smile.png
            └── smile@2x.png
```

### Сборка спрайта

* В папке `dist/assets/images/sprites` появятся два спрайта: обычный и Retina с `@2x` и в `app/styles/sprites` один стилевой файл с примесями. Все файлы будут с такими же названиями, как у папки, в которой находятся его иконки. Например:
```
├── frontend/
│    └── styles/
│       └── sprites/
│           └── emoji.styl
└── public_html/
    └── assets/
        └── img/
            └── sprites/
                ├── emoji.png
                └── emoji@2x.png

```

* В сборочных папках останутся только актуальные спрайты и стили в случае, если удалить исходные папки с иконками.

### Использование png-спрайтов

#### Retina спрайты

Для подключения иконки используется примесь `retinaSprite` со значением `$icon_group`, где `icon` это название PNG иконки, например:
```css
.joy
    retinaSprite $joy_group
```

В собранном виде в CSS добавятся обычный спрайт и медиа-запрос, чтобы отображать Retina спрайт только при необходимости и это будет выглядеть так:
```css
.joy {
    background-image: url("../images/sprites/emoji.png");
    background-position: 32px 0px;
    width: 24px;
    height: 24px;
}

@media (-webkit-min-device-pixel-ratio: 2), (min-resolution: 192dpi) {
    .joy {
        background-image: url("../images/sprites/emoji@2x.png");
        background-size: 88px 24px;
    }
}
```

#### Обычные спрайты

Для подключения иконки используется примесь `sprite` со значением `$icon`, где `icon` это название PNG иконки, например:
```css
.joy
    sprite $joy
```

В собранном виде в CSS добавится только обычный спрайт и это будет выглядеть так:
```css
.joy {
    background-image: url("../images/sprites/emoji.png");
    background-position: 32px 0px;
    width: 24px;
    height: 24px;
}
```


## Other gulp tasks

Сборка стилей `publi_html/assets/css/` и `frontend/css`
```bash
  gulp styles
```

Сборка скриптов в `publi_html/assets/js/scripts.min.js` и `frontend/js/scripts.min.js`
```bash
  gulp sсripts
```

Сборка статики в `publi_html/static`
```bash
  gulp jade
```

Копирование шрифтов в `publi_html/assets/fonts`
```bash
  gulp fonts
```

Сжатие и копирование картинок в `publi_html/assets/img`
```bash
  gulp img
```

Сжатие svg и формирование спрайта, так же создание png-изображений для fallback'ов
```bash
  gulp svg
```

Запускает линтера  для проверки js-модулей
```bash
  gulp lint
```

Запускает watcher'a
```bash
  gulp watch
```

Дефолтный таск - запускает watcher'a и hot-reload
```bash
  gulp
```
Открывается при помощи browser-sync на вашем локалхосте, который смотрит внурь `public_html`.

