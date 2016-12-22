
/**
 * @module       RD Parallax
 * @author       Evgeniy Gusarov
 * @see          https://ua.linkedin.com/pub/evgeniy-gusarov/8a/a40/54a
 * @version      3.6.5
 */

(function() {
  (function($, document, window) {

    /**
     * Compatibility flags
     */
    var RDParallax, chromeVersion, hasClassList, isChrome, isChromeIOS, isChromeNew, isIE, isMobile, isSafariIOS, isWebkit, isWin8;
    isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
    isChrome = /Chrome/.test(navigator.userAgent);
    isWebkit = (/Chrome/.test(navigator.userAgent) && /Google Inc/.test(navigator.vendor)) || (/Safari/.test(navigator.userAgent) && /Apple Computer/.test(navigator.vendor));
    isChromeIOS = isMobile && /crios/i.test(navigator.userAgent);
    isSafariIOS = /iPhone|iPad|iPod/i.test(navigator.userAgent) && !!navigator.userAgent.match(/Version\/[\d\.]+.*Safari/);
    isIE = navigator.appVersion.indexOf("MSIE") !== -1 || navigator.appVersion.indexOf('Trident/') > -1;
    isWin8 = /windows nt 6.2/.test(navigator.userAgent.toLowerCase()) || /windows nt 6.3/.test(navigator.userAgent.toLowerCase());
    hasClassList = document.body.classList != null;
    chromeVersion = isChrome ? navigator.userAgent.replace(/^.*Chrome\/([\d\.]+).*$/i, '$1') : false;
    isChromeNew = chromeVersion >= '55.0.2883.75';

    /**
     * The requestAnimationFrame polyfill
     * http://paulirish.com/2011/requestanimationframe-for-smart-animating/
     */
    (function() {
      var k, lastTime, len, vendor, vendors;
      lastTime = 0;
      vendors = ['ms', 'moz', 'webkit', 'o'];
      for (k = 0, len = vendors.length; k < len; k++) {
        vendor = vendors[k];
        window.requestAnimationFrame = window[vendor + "RequestAnimationFrame"];
        window.cancelAnimationFrame = window[vendor + "CancelAnimationFrame"] || window[vendor + "CancelRequestAnimationFrame"];
      }
      if (!window.requestAnimationFrame) {
        window.requestAnimationFrame = function(callback, element) {
          var currTime, id, timeToCall;
          currTime = new Date().getTime();
          timeToCall = Math.max(0, 16 - (currTime - lastTime));
          id = window.setTimeout(function() {
            callback(currTime + timeToCall);
          }, timeToCall);
          lastTime = currTime + timeToCall;
          return id;
        };
      }
      if (!window.cancelAnimationFrame) {
        return window.cancelAnimationFrame = function(id) {
          return clearTimeout(id);
        };
      }
    });

    /**
     * Creates a parallax.
     * @class RDParallax.
     * @public
     * @param {HTMLElement} element - The element to create the parallax for.
     * @param {Object} [options] - The options
     */
    RDParallax = (function() {

      /**
       * Creates a parallax layer.
       * @class Layer.
       * @public
       * @param {HTMLElement} element - The element to create a layer for.
       * @param {object} aliases - An object with width breakpoints aliases
       * @param {numbeer} windowWidth - current window width
       */
      var Layer, Scene;

      Layer = (function() {
        function Layer(element, aliases, windowWidth, windowHeight, sceneOffset, sceneHeight, sceneOn) {
          var ref, ref1;
          this.amend = (ref = (ref1 = isWebkit || isIE || isMobile) != null ? ref1 : isChromeNew) != null ? ref : {
            0: {
              60: 0
            }
          };
          this.element = element;
          this.aliases = aliases;
          this.type = element.getAttribute("data-type") || "html";
          if (this.type === "html") {
            this.holder = this.createHolder();
          }
          this.direction = element.getAttribute("data-direction") === "normal" || (element.getAttribute("data-direction") == null) ? 1 : -1;
          this.fade = element.getAttribute("data-fade") === "true";
          this.blur = element.getAttribute("data-blur") === "true";
          this.boundTo = document.querySelector(element.getAttribute("data-bound-to"));
          if (this.type === "media") {
            this.url = element.getAttribute("data-url");
          }
          this.responsive = this.getResponsiveOptions();
          if ((!isIE && !isMobile) || isMobile || (isWin8 && isIE)) {
            this.element.style["position"] = "absolute";
          } else {
            this.element.style["position"] = "fixed";
          }
          switch (this.type) {
            case "media":
              if (this.url != null) {
                this.element.style["background-image"] = "url(" + this.url + ")";
              }
              break;
            case "html":
              if (isIE && isMobile) {
                this.element.style["z-index"] = 1;
              }
          }
          this.refresh(windowWidth, windowHeight, sceneOffset, sceneHeight, sceneOn);
          return;
        }


        /**
        * Refresh layer size statements
        * @param {number} window width
        * @public
         */

        Layer.prototype.refresh = function(windowWidth, windowHeight, sceneOffset, sceneHeight, sceneOn) {
          var layer;
          layer = this;
          layer.speed = layer.getOption("speed", windowWidth) || 0;
          layer.offset = layer.getOption("offset", windowWidth) || 0;
          if (!isMobile && !(isWin8 && isIE)) {
            if (sceneOn) {
              layer.element.style["position"] = "fixed";
            } else {
              layer.element.style["position"] = "absolute";
            }
          }
          if (isIE && layer.type === "html") {
            layer.element.style["position"] = "absolute";
          }
          switch (layer.type) {
            case "media":
              if (!isIE) {
                layer.offsetHeight = layer.getMediaHeight(windowHeight, sceneHeight, layer.speed, layer.direction);
                return layer.element.style["height"] = layer.offsetHeight + "px";
              }
              break;
            case "html":
              layer.element.style["width"] = this.holder.offsetWidth + "px";
              layer.offsetHeight = layer.element.offsetHeight;
              layer.holder.style["height"] = layer.offsetHeight + "px";
              if ((!isIE && !isMobile) || isMobile || (isWin8 && isIE)) {

              } else {
                if (isIE) {
                  layer.element.style["position"] = "static";
                } else if (sceneOn) {
                  layer.element.style["left"] = (layer.getOffset(layer.holder).left) + "px";
                  layer.element.style["top"] = (layer.getOffset(layer.holder).top - sceneOffset) + "px";
                }
                return layer.holder.style["position"] = "static";
              }
              break;
            case "custom":
              return layer.offsetHeight = layer.element.offsetHeight;
          }
        };


        /**
        * Creates a static layer holder element
        * @public
        * @returns {element} holder
         */

        Layer.prototype.createHolder = function() {
          var holder, layer;
          layer = this;
          holder = document.createElement("div");
          if (hasClassList) {
            holder.classList.add("rd-parallax-layer-holder");
          } else {
            holder.className = "rd-parallax-layer-holder";
          }
          layer.element.parentNode.insertBefore(holder, layer.element);
          holder.appendChild(layer.element);
          if ((!isIE && !isMobile) || isChromeIOS) {
            holder.style["position"] = "relative";
          }
          return holder;
        };


        /**
        * Creates a static layer holder element
        * @public
        * @returns {element} holder
         */

        Layer.prototype.isHolderWrong = function() {
          var layer;
          layer = this;
          if (layer.type === "html") {
            if (layer.holder.offsetHeight !== layer.element.offsetHeight) {
              return true;
            }
          }
          return false;
        };


        /**
        * Gets specific option of layer
        * @public
        * @param {string} key
        * @param {number} window width
        * @returns {object} value
         */

        Layer.prototype.getOption = function(key, windowWidth) {
          var layer, point, targetPoint;
          layer = this;
          for (point in layer.responsive) {
            if (point <= windowWidth) {
              targetPoint = point;
            }
          }
          return layer.responsive[targetPoint][key];
        };


        /**
        * Creates a set of responsive options of the layer
        * @public
        * @returns {object} options
         */

        Layer.prototype.getResponsiveOptions = function() {
          var alias, aliases, i, j, k, len, point, ref, resolutions, responsive, value;
          responsive = {};
          resolutions = [];
          aliases = [];
          ref = this.aliases;
          for (i in ref) {
            alias = ref[i];
            resolutions.push(i);
            aliases.push(alias);
          }
          for (i = k = 0, len = resolutions.length; k < len; i = ++k) {
            point = resolutions[i];
            responsive[point] = {};
            while ((j = i) >= -1) {
              if (!responsive[point]["speed"] && (value = this.element.getAttribute("data" + aliases[j] + "speed"))) {
                responsive[point]["speed"] = this.getSpeed(value);
              }
              if (!responsive[point]["offset"] && (value = this.element.getAttribute("data" + aliases[j] + "offset"))) {
                responsive[point]["offset"] = parseInt(value);
              }
              if (!responsive[point]["fade"] && (value = this.element.getAttribute("data" + aliases[j] + "fade"))) {
                responsive[point]["fade"] = value === 'true';
              }
              i--;
            }
          }
          return responsive;
        };


        /**
        * Fade layer according to its position in scene
        * @public
        * @param {number} sceneOffset - current scene offset
        * @param {number} sceneHeight - current scene height
         */

        Layer.prototype.fuse = function(sceneOffset, sceneHeight) {
          var layer, layerDevider, offsetTop, opacity, pos, sceneDevider;
          layer = this;
          offsetTop = layer.getOffset(layer.element).top + layer.element.getBoundingClientRect().top;
          sceneDevider = sceneOffset + sceneHeight / 2.0;
          layerDevider = offsetTop + layer.offsetHeight / 2.0;
          pos = sceneHeight / 6.0;
          if (sceneDevider + pos > layerDevider && sceneDevider - pos < layerDevider) {
            layer.element.style["opacity"] = 1;
          } else {
            if (sceneDevider - pos < layerDevider) {
              opacity = 1 + ((sceneDevider + pos - layerDevider) / sceneHeight / 3.0 * 10);
            } else {
              opacity = 1 - ((sceneDevider - pos - layerDevider) / sceneHeight / 3.0 * 10);
            }
            layer.element.style["opacity"] = opacity < 0 ? 0 : opacity > 1 ? 1 : opacity.toFixed(2);
          }
        };


        /**
        * Move layer in scene
        * @public
        * @param {number} scrollY - current scroll top
        * @param {number} windowWidth - current window width
        * @param {number} windowHeight - current window height
        * @param {number} sceneOffset - current scene offset top
        * @param {number} sceneHeight - current scene height
        * @param {number} documentHeight - current scene height
        * @param {number} agentOffset - current agent offset
         */

        Layer.prototype.move = function(scrollY, windowWidth, windowHeight, sceneOffset, sceneHeight, documentHeight, sceneOn, agentOffset, inputFocus) {
          var dy, h, layer, pos, v;
          layer = this;
          if (isIE && layer.type === "media") {
            return;
          }
          if (isMobile || (isWin8 && isIE)) {
            return;
          }
          if (!sceneOn) {
            if (isWebkit) {
              layer.element.style["-webkit-transform"] = "translate3d(0,0,0)";
            }
            layer.element.style["transform"] = "translate3d(0,0,0)";
            return;
          }
          if ((!isMobile) || (layer.type === "html" && inputFocus) || isChromeIOS) {
            v = layer.speed * layer.direction;
          } else {
            v = layer.speed * layer.direction - 1;
          }
          h = layer.offsetHeight;
          if (agentOffset != null) {
            dy = (sceneOffset + windowHeight - (agentOffset + windowHeight)) / (windowHeight - sceneHeight);
          } else if (layer.type !== "media") {
            if (sceneOffset < windowHeight || sceneOffset > documentHeight - windowHeight) {
              if (sceneOffset < windowHeight) {
                dy = sceneOffset / (windowHeight - sceneHeight);
              } else {
                dy = (sceneOffset + windowHeight - documentHeight) / (windowHeight - sceneHeight);
              }
              if (!isFinite(dy)) {
                dy = 0;
              }
            } else {
              dy = 0.5;
            }
          } else {
            dy = 0.5;
          }
          if (isChromeIOS || isIE) {
            pos = (sceneHeight - h) / 2 + (windowHeight - sceneHeight) * dy * v + layer.offset;
          } else if (isMobile) {
            pos = -(sceneOffset - scrollY) * v + (sceneHeight - h) / 2 + (windowHeight - sceneHeight) * dy * (v + 1) + layer.offset;
          } else {
            pos = -(sceneOffset - scrollY) * v + (sceneHeight - h) / 2 + (windowHeight - sceneHeight) * dy * v + layer.offset;
          }
          if (isMobile) {
            if (agentOffset != null) {
              layer.element.style["top"] = (sceneOffset - agentOffset) + "px";
            }
          }
          if (isWebkit) {
            this.element.style["-webkit-transform"] = "translate3d(0," + pos + "px,0)";
          }
          this.element.style["transform"] = "translate3d(0," + pos + "px,0)";
        };


        /**
        * Normalize layer speed
        * @public
        * @param {number} value - speed
        * @returns {number} normalized speed
         */

        Layer.prototype.getSpeed = function(value) {
          return Math.min(Math.max(parseFloat(value), 0), 2.0);
        };


        /**
        * Calculate media layer height
        * @public
        * @param {number} windowHeight - current window height
        * @param {number} sceneHeight - current scene height
        * @param {number} speed - current speed
        * @param {number} direction - movement direction
        * @returns {number} media layer height
         */

        Layer.prototype.getMediaHeight = function(windowHeight, sceneHeight, speed, direction) {
          var directionModifier;
          directionModifier = direction === -1 ? (sceneHeight + windowHeight) * speed : 0;
          return (sceneHeight + directionModifier + (speed <= 1 ? Math.abs(windowHeight - sceneHeight) * speed : windowHeight * speed)) + this.amend * 2;
        };


        /**
         * Calc the element offset relative to document. Method is similar to $.offset()
         * @public
         * @param {element} element - HTML Element
         * @returns {object} top and left offsets
         */

        Layer.prototype.getOffset = function(element) {
          var bound, left, top;
          bound = element.getBoundingClientRect();
          left = bound.left + (window.scrollX || window.pageXOffset);
          top = bound.top + (window.scrollY || window.pageYOffset);
          return {
            top: top,
            left: left
          };
        };

        return Layer;

      })();


      /**
       * Creates a parallax scene.
       * @class Scene.
       * @public
       * @param {HTMLElement} element - The element to create a scene for.
       * @param {object} aliases - An object with width breakpoints aliases
       * @param {numbeer} windowWidth - current window width
       */

      Scene = (function() {
        function Scene(element, aliases, windowWidth, windowHeight) {
          var ref, scene;
          scene = this;
          scene.amend = (ref = isWebkit != null ? isWebkit : isChromeNew) != null ? ref : {
            0: {
              60: 0
            }
          };
          scene.element = element;
          scene.aliases = aliases;
          scene.on = true;
          scene.agent = document.querySelector(element.getAttribute("data-agent"));
          scene.anchor = scene.findAnchor();
          scene.canvas = scene.createCanvas();
          scene.layers = scene.createLayers(windowWidth);
          scene.fitTo = scene.getFitElement();
          scene.responsive = scene.getResponsiveOptions();
          scene.refresh(windowWidth, windowHeight);
        }


        /**
         * Finds an element that layer will fit to
         * @public
         * @returns {element} fit element
         */

        Scene.prototype.getFitElement = function() {
          var fitTo, scene;
          scene = this;
          if ((fitTo = scene.element.getAttribute("data-fit-to")) != null) {
            if (fitTo === "parent") {
              return scene.element.parentNode;
            } else {
              return document.querySelector(fitTo);
            }
          } else {
            return null;
          }
        };


        /**
         * Checks if parallax scene is inside of element with CSS Transform
         * @public
         * @returns {element} Parent element with CSS Transform or null
         */

        Scene.prototype.findAnchor = function() {
          var parent, scene;
          scene = this;
          parent = scene.element.parentNode;
          while ((parent != null) && parent !== document) {
            if (scene.isTransformed.call(parent)) {
              return parent;
            }
            parent = parent.parentNode;
          }
          return null;
        };


        /**
         * Creates a parallax canvas element
         * @public
         * @returns {element} canvas
         */

        Scene.prototype.createCanvas = function() {
          var canvas, scene;
          scene = this;
          canvas = document.createElement("div");
          if (hasClassList) {
            canvas.classList.add("rd-parallax-inner");
          } else {
            canvas.className = "rd-parallax-inner";
          }
          scene.element.appendChild(canvas);
          while (scene.element.firstChild !== canvas) {
            canvas.appendChild(scene.element.firstChild);
          }
          scene.element.style["position"] = "relative";
          scene.element.style["overflow"] = "hidden";
          if (!isIE && !isMobile) {
            canvas.style["position"] = "fixed";
          } else {
            canvas.style["position"] = "absolute";
            if (!(isWin8 && isIE)) {
              canvas.style["clip"] = "rect(0, auto, auto, 0)";
            }
            if (isIE) {
              canvas.style["transform"] = "translate3d(0,0,0)";
            } else {
              canvas.style["transform"] = "none";
            }
          }
          canvas.style["left"] = scene.offsetLeft + "px";
          canvas.style["top"] = 0;
          if (isWebkit) {
            canvas.style["margin-top"] = "-" + scene.amend + "px";
            canvas.style["padding"] = scene.amend + "px 0";
            scene.element.style["z-index"] = 0;
          }
          return canvas;
        };


        /**
        * Gets specific option of layer
        * @public
        * @param {string} key
        * @param {number} window width
        * @returns {object} value
         */

        Scene.prototype.getOption = function(key, windowWidth) {
          var point, targetPoint;
          for (point in this.responsive) {
            if (point <= windowWidth) {
              targetPoint = point;
            }
          }
          return this.responsive[targetPoint][key];
        };


        /**
         * Creates a set of responsive options of the layer
         * @public
         * @returns {object} options
         */

        Scene.prototype.getResponsiveOptions = function() {
          var alias, aliases, i, j, k, len, point, ref, resolutions, responsive, value;
          responsive = {};
          resolutions = [];
          aliases = [];
          ref = this.aliases;
          for (i in ref) {
            alias = ref[i];
            resolutions.push(i);
            aliases.push(alias);
          }
          for (i = k = 0, len = resolutions.length; k < len; i = ++k) {
            point = resolutions[i];
            responsive[point] = {};
            while ((j = i) >= -1) {
              if (!responsive[point]["on"] && ((value = this.element.getAttribute("data" + aliases[j] + "on")) != null)) {
                responsive[point]["on"] = value !== "false";
              }
              if ((responsive[point]["on"] == null) && j === 0) {
                responsive[point]["on"] = true;
              }
              i--;
            }
          }
          return responsive;
        };


        /**
         * Creates the layers of parallax
         * @public
         * @param {number} window width
         * @returns {array} List of layers
         */

        Scene.prototype.createLayers = function(windowWidth, windowHeight) {
          var element, elements, i, k, layers, len, scene;
          scene = this;
          elements = $(scene.element).find(".rd-parallax-layer").get();
          layers = [];
          for (i = k = 0, len = elements.length; k < len; i = ++k) {
            element = elements[i];
            layers.push(new Layer(element, scene.aliases, windowWidth, windowHeight, scene.offsetTop, scene.offsetHeight, scene.on));
          }
          return layers;
        };


        /**
         * Update scene position
         * @public
         */

        Scene.prototype.move = function(scrollY) {
          var pos, scene;
          scene = this;
          if (scene.anchor != null) {
            pos = scene.positionTop;
          } else {
            pos = scene.offsetTop - scrollY;
          }
          if (isWebkit) {
            scene.canvas.style["-webkit-transform"] = "translate3d(0," + pos + "px,0)";
          }
          return scene.canvas.style["transform"] = "translate3d(0," + pos + "px,0)";
        };


        /**
         * Refresh scene dimensions
         * @param {number} windowWidth - current window width
         * @param {number} windowHeight - current window height
         * @public
         */

        Scene.prototype.refresh = function(windowWidth, windowHeight) {
          var k, l, layer, len, len1, mediaLayers, ref, scene;
          scene = this;
          mediaLayers = [];
          scene.on = scene.getOption("on", windowWidth);
          scene.offsetTop = scene.getOffset(scene.element).top;
          scene.offsetLeft = scene.getOffset(scene.element).left;
          scene.width = scene.element.offsetWidth;
          scene.canvas.style["width"] = scene.width + "px";
          if (scene.anchor != null) {
            scene.positionTop = scene.element.offsetTop;
          }
          if (scene.agent != null) {
            scene.agentOffset = scene.getOffset(scene.agent).top;
            scene.agentHeight = scene.agent.offsetHeight;
          } else {
            scene.agentOffset = scene.agentHeight = null;
          }
          ref = scene.layers;
          for (k = 0, len = ref.length; k < len; k++) {
            layer = ref[k];
            if (layer.type === "media") {
              mediaLayers.push(layer);
            } else {
              layer.refresh(windowWidth, windowHeight, scene.offsetTop, scene.offsetHeight, scene.on);
            }
          }
          scene.offsetHeight = scene.canvas.offsetHeight - scene.amend * 2;
          scene.element.style["height"] = scene.offsetHeight + "px";
          for (l = 0, len1 = mediaLayers.length; l < len1; l++) {
            layer = mediaLayers[l];
            layer.refresh(windowWidth, windowHeight, scene.offsetTop, scene.offsetHeight, scene.on);
          }
        };


        /**
         * Update scene act
         * @public
         */

        Scene.prototype.update = function(scrollY, windowWidth, windowHeight, documentHeight, inputFocus) {
          var k, layer, len, ref, results, scene, sceneHeight, sceneOffset;
          scene = this;
          sceneOffset = scene.offsetTop;
          sceneHeight = scene.offsetHeight;
          if (!isIE && (!isMobile)) {
            scene.move(scrollY);
          }
          ref = scene.layers;
          results = [];
          for (k = 0, len = ref.length; k < len; k++) {
            layer = ref[k];
            layer.move(scrollY, windowWidth, windowHeight, sceneOffset, sceneHeight, documentHeight, scene.on, scene.agentOffset, inputFocus);
            layer.fade = layer.getOption("fade", windowWidth) || false;
            if (layer.fade && !isMobile && !isIE) {
              results.push(layer.fuse(sceneOffset, sceneHeight));
            } else {
              results.push(void 0);
            }
          }
          return results;
        };


        /**
         * Checks if element is transformed
         * @public
         * @returns {boolean}
         */

        Scene.prototype.isTransformed = function() {
          var el, t, transformed, transforms;
          el = this;
          transforms = {
            'webkitTransform': '-webkit-transform',
            'OTransform': '-o-transform',
            'msTransform': '-ms-transform',
            'MozTransform': '-moz-transform',
            'transform': 'transform'
          };
          for (t in transforms) {
            if (transforms.hasOwnProperty(t)) {
              if (el.style[t] != null) {
                transformed = window.getComputedStyle(el).getPropertyValue(transforms[t]);
              }
            }
          }
          if ((transformed != null) && transformed.length > 0 && transformed !== "none") {
            return true;
          } else {
            return false;
          }
        };


        /**
         * Calc the element offset relative to document. Method is similar to $.offset()
         * @public
         * @param {element} element - HTML Element
         * @returns {object} top and left offsets
         */

        Scene.prototype.getOffset = function(element) {
          var bound, left, top;
          bound = element.getBoundingClientRect();
          left = bound.left + (window.scrollX || window.pageYOffset);
          top = bound.top + (window.scrollY || window.pageYOffset);
          return {
            top: top,
            left: left
          };
        };

        return Scene;

      })();


      /**
       * Default options for parallax.
       * @public
       */

      RDParallax.prototype.Defaults = {
        selector: '.rd-parallax',
        screenAliases: {
          0: '-',
          480: '-xs-',
          768: '-sm-',
          992: '-md-',
          1200: '-lg-',
          1920: '-xl-',
          2560: '-xxl-'
        }
      };

      function RDParallax(options) {
        this.options = $.extend(true, {}, this.Defaults, options);
        this.scenes = [];
        this.initialize();
        this.scrollY = window.scrollY || window.pageYOffset;
        this.lastScrollY = -1;
        this.lastDocHeight = 0;
        this.inputFocus = false;
        this.checkLayerHeight = false;
      }


      /**
       * Initializes the Parallax.
       * @public
       */

      RDParallax.prototype.initialize = function() {
        var ctx, element, elements, i, k, len, windowHeight, windowWidth;
        ctx = this;
        elements = document.querySelectorAll(ctx.options.selector);
        windowWidth = window.innerWidth;
        windowHeight = window.innerHeight;
        for (i = k = 0, len = elements.length; k < len; i = ++k) {
          element = elements[i];
          ctx.scenes.push(new Scene(element, ctx.options.screenAliases, windowWidth, windowHeight));
        }
        $(window).on("resize", $.proxy(ctx.resize, ctx));
        if (isSafariIOS) {
          $('input').on("focusin focus", function(e) {
            e.preventDefault();
            ctx.activeOffset = $(this).offset().top;
            return window.scrollTo(window.scrollX || window.pageXOffset, ctx.activeOffset - this.offsetHeight - 100);
          });
        }
        $(window).trigger("resize");
        ctx.update();
        ctx.checkResize();
      };


      /**
       * Resize all scenes
       * @public
       */

      RDParallax.prototype.resize = function(forceResize) {
        var ctx, currentWindowWidth, k, len, ref, scene;
        ctx = this;
        if ((currentWindowWidth = window.innerWidth) !== ctx.windowWidth || !isMobile || forceResize) {
          ctx.windowWidth = currentWindowWidth;
          ctx.windowHeight = window.innerHeight;
          ctx.documentHeight = document.body.offsetHeight;
          ref = ctx.scenes;
          for (k = 0, len = ref.length; k < len; k++) {
            scene = ref[k];
            scene.refresh(ctx.windowWidth, ctx.windowHeight);
          }
          return ctx.update(true);
        }
      };


      /**
       * Update all parallax scenes
       * @param {boolean} forceUpdate - force scenes update if scroll wasnt triggered
       * @public
       */

      RDParallax.prototype.update = function(forceUpdate) {
        var activeElement, ctx, deltaHeight, deltaScroll, documentHeight, k, len, ref, scene, scrollY, windowHeight, windowWidth;
        ctx = this;
        if (!forceUpdate) {
          requestAnimationFrame(function() {
            ctx.update();
          });
        }
        scrollY = window.scrollY || window.pageYOffset;
        if (isSafariIOS) {
          if ((activeElement = document.activeElement) != null) {
            if (activeElement.tagName.match(/(input)|(select)|(textarea)/i)) {
              ctx.activeElement = activeElement;
              ctx.inputFocus = true;
            } else {
              ctx.activeElement = null;
              ctx.inputFocus = false;
              forceUpdate = true;
            }
          }
        }
        if (isMobile && isChrome) {
          deltaHeight = window.innerHeight - ctx.windowHeight;
          ctx.deltaHeight = deltaHeight;
          scrollY -= ctx.deltaHeight;
        }
        if (((scrollY !== ctx.lastScrollY) || forceUpdate) && !ctx.isActing) {
          ctx.isActing = true;
          windowWidth = ctx.windowWidth;
          windowHeight = ctx.windowHeight;
          documentHeight = ctx.documentHeight;
          deltaScroll = scrollY - ctx.lastScrollY;
          if (isSafariIOS) {
            if (ctx.activeElement != null) {
              ctx.activeElement.value = ctx.activeElement.value + " ";
              ctx.activeElement.value = ctx.activeElement.value.trim();
            }
          }
          ref = ctx.scenes;
          for (k = 0, len = ref.length; k < len; k++) {
            scene = ref[k];
            if (ctx.inputFocus || forceUpdate || (scrollY + windowHeight >= (scene.agentOffset || scene.offsetTop) + deltaScroll && scrollY <= (scene.agentOffset || scene.offsetTop) + (scene.agentHeight || scene.offsetHeight) + deltaScroll)) {
              scene.update(scrollY, windowWidth, windowHeight, documentHeight, ctx.inputFocus);
            }
          }
          ctx.lastScrollY = scrollY;
          return ctx.isActing = false;
        }
      };

      RDParallax.prototype.checkResize = function() {
        var ctx;
        ctx = this;
        setInterval(function() {
          var docHeight, k, l, layer, len, len1, ref, ref1, scene;
          docHeight = document.body.offsetHeight;
          ref = ctx.scenes;
          for (k = 0, len = ref.length; k < len; k++) {
            scene = ref[k];
            ref1 = scene.layers;
            for (l = 0, len1 = ref1.length; l < len1; l++) {
              layer = ref1[l];
              if (layer.isHolderWrong()) {
                ctx.checkLayerHeight = true;
                break;
              }
            }
            if (ctx.checkLayerHeight) {
              break;
            }
          }
          if (ctx.checkLayerHeight || docHeight !== ctx.lastDocHeight) {
            ctx.resize(true);
            ctx.lastDocHeight = docHeight;
            return ctx.checkLayerHeight = false;
          }
        }, 500);
      };

      return RDParallax;

    })();

    /**
     * The jQuery Plugin for the RD Parallax
     * @public
     */
    $.RDParallax = function(options) {
      var $doc;
      $doc = $(document);
      if (!$doc.data('RDParallax')) {
        return $doc.data('RDParallax', new RDParallax(options));
      }
    };
    return window.RDParallax = RDParallax;
  })(window.jQuery, document, window);


  /**
   * The Plugin AMD export
   * @public
   */

  if (typeof module !== "undefined" && module !== null) {
    module.exports = window.RDParallax;
  } else if (typeof define === 'function' && define.amd) {
    define(["jquery"], function() {
      'use strict';
      return window.RDParallax;
    });
  }

}).call(this);
