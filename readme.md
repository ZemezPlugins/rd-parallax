# RD Parallax

Flexible multilayer parallax effect. Easy integration with other plugins

Check out this [Demo](http://cms.devoffice.com/coding-dev/rd-parallax/demo/) to see it in action!

Extended documentation is available here: [Documentation](http://cms.devoffice.com/coding-dev/rd-parallax/documentation/)

## Setup
The HTML markdown is really simple. Just create a set of layers that you want to move within your parallax scene giving
each layer a class ``rd-parallax-layer`` and some additional data attributes.

```html
<!-- RD Parallax -->
<section class="rd-parallax"></section>
  <!-- Creates a parallax media layer recalculating its height according to scene height -->
  <div class="rd-parallax-layer" data-speed="0.2" data-type="media" data-url="path/to/your-image.jpg"></div>
  <!-- Creates a static flow html layer -->
  <div class="rd-parallax-layer" data-speed="0.3" data-type="html" data-fade="true">
    <!-- Your static content goes here-->
  </div>
</section>
<!-- END RD Parallax-->
```

_Note: You can use any content if you want for media layer, such as background videos etc. Just remove ``data-url``
attribute and put your content inside the media layer_

Apply the parallax styles to the scene

```html
<link rel="stylesheet" href="path/to/css/rd-parallax.css">
```

Finally, initialize the script

```js
$(document).ready(function () {
    o.RDParallax({}); // Additional options
});
```

## Further Customization

Check out our extended documentation for additional instructions: [Documentation](http://cms.devoffice.com/coding-dev/rd-parallax/documentation/)

## License
Licensed under dual [CC By-SA 4.0](http://creativecommons.org/licenses/by-sa/4.0/)
and [GPLv3](http://www.gnu.org/licenses/gpl-3.0.ru.html)

