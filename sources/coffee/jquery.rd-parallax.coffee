###*
 * @module       RD Parallax
 * @author       Evgeniy Gusarov
 * @see          https://ua.linkedin.com/pub/evgeniy-gusarov/8a/a40/54a
 * @version      3.0.0
###
(($, document, window) ->
  ###*
   * Initial flags
   * @public
  ###
  isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
  isFirefox = typeof InstallTrigger isnt 'undefined'
  isIE = navigator.appVersion.indexOf("MSIE") isnt -1
  ieVersion = if isIE then parseInt(navigator.appVersion.split("MSIE")[1]) else null

  ###*
   * Creates a parallax.
   * @class RDParallax.
   * @public
   * @param {HTMLElement} element - The element to create the parallax for.
   * @param {Object} [options] - The options
  ###
  class RDParallax

    ###*
     * Default options for parallax.
     * @public
    ###
    Defaults:
      blur: true
      direction: 'inverse'
      speed: 1
      duration: 200
      easing: 'linear'
      screenAliases: {
        0: ''
        480: 'xs'
        768: 'sm'
        992: 'md'
        1200: 'lg'
      }

    constructor: (element, options) ->
      @options = $.extend(true, {}, @Defaults, options)
      @$element = $(element)
      @$win = $(window)
      @$doc = $(document)
      @initialize()

    ###*
     * Initializes the Parallax.
     * @protected
    ###
    initialize: () ->
      ctx = @

      ctx
        .$element
        .wrapInner($('<div/>', {"class": "rd-parallax-inner"}))
        .find(".rd-parallax-layer[data-type]")
        .each ->
          layer = $(@)

          switch layer.attr("data-type").toLowerCase()
            when "media"
              # Build Image media
              if url = @.getAttribute("data-url")
                layer.css({
                  "background-image" : ctx.url(url)
                })

                # Create Media Blur handler
                if @.getAttribute("data-blur") == "true" or ctx.options.blur
                  $('<img/>', {src: url}).load(() ->
                      layer.attr("data-media-width", this.width)
                      layer.attr("data-media-height", this.height)
                      ctx.$win.on("resize", $.proxy(ctx.blurMedia, layer[0], ctx))
#                      ctx.$win.on("orientationchange", $.proxy(ctx.blurMedia, layer[0], ctx)) if isMobile
                      $.proxy(ctx.blurMedia, layer[0], ctx)()
                  )

              # Create resize handlers
              if !isMobile
                ctx.$element.on("resize", $.proxy(ctx.resizeMedia, @, ctx))
                ctx.$element.on("resize", $.proxy(ctx.moveLayer, @, ctx))
                ctx.$win.on("resize", $.proxy(ctx.resizeMedia, @, ctx))
#                ctx.$win.on("orientationchange", $.proxy(ctx.resizeMedia, @, ctx)) if isMobile

          if !isMobile
            # Create Document scroll handler
            ctx.$doc.on("scroll", $.proxy(ctx.moveLayer, @, ctx))
            ctx.$doc.on("resize", $.proxy(ctx.moveLayer, @, ctx))

            # Create Layer fade handler
            ctx.$doc.on("scroll", $.proxy(ctx.fadeLayer, @, ctx)) if @.getAttribute("data-fade") == "true" and !isIE
            ctx.$doc.on("resize", $.proxy(ctx.fadeLayer, @, ctx)) if @.getAttribute("data-fade") == "true" and !isIE
          return

      # Trigger Initial Events
      ctx.$win.trigger("resize")
      ctx.$doc.trigger("scroll")
      return


    ###*
     * Moves Layer
     * @param {object} ctx
     * @protected
    ###
    moveLayer: (ctx) ->
      scrt = ctx.$win.scrollTop()
      offt = ctx.$element.offset().top
      wh = ctx.$win.height()
      ch = ctx.$element.height()
      h = @.offsetHeight
      v = Math.max(parseFloat(v), 0)
      dir = if ctx.getAttribute(@, 'direction') is "inverse" then -1 else 1
      v = dir * Math.min(parseFloat(ctx.getAttribute(@, 'speed')), 2.0)

      pos = -(offt - scrt) * v + (ch - h)/2 + (wh - ch)/2 * v

      $(@)
        .css(ctx.transform(pos, ctx))


    ###*
     * Fade Layer
     * @param {object} ctx
     * @protected
    ###
    fadeLayer: (ctx, e) ->
      layer = $(@)
      ch = ctx.$element.height()
      coff = ctx.$element.offset().top + ch/2
      loff = layer.offset().top + layer.height()/2
      pos = ch / 6.0

      if coff + pos > loff and coff - pos < loff
        layer.css({"opacity": 1})
      else
        if coff - pos < loff
          o = 1 + ((coff + pos - loff) / ch / 3.0 * 10)
        else
          o = 1 - ((coff - pos - loff) / ch / 3.0 * 10)
        layer.css({"opacity": if o < 0 then 0 else if o > 1 then 1 else o.toFixed(2)})

    ###*
     * Blurs Layer
     * @param {object} ctx
     * @protected
    ###
    blurMedia: (ctx) ->
      h = @.offsetHeight
      w = @.offsetWidth
      mh = parseFloat(@.getAttribute("data-media-height"))
      mw = parseFloat(@.getAttribute("data-media-width"))

      blur = Math.ceil(Math.max(h / mh, w / mw));

      $(@).css(ctx.blur(blur))

    ###*
     * Resize Media Layer
     * @param {object} ctx
     * @protected
    ###
    resizeMedia: (ctx) ->
      @.style.height = ctx.px(ctx.getMediaHeight(
        ctx.$win.height(),
        ctx.$element.height(),
        ctx.getAttribute(@, 'speed'),
        if ctx.getAttribute(@, 'direction') is "inverse" then -1 else 1
      ))


    ###*
     * Calc media layer height.
     * @param {number} wh
     * @param {number} v
     * @returns {number} media layer height
     * @protected
    ###
    getMediaHeight: (wh, ch, v, dir) ->
      v = Math.max(parseFloat(v), 0)
      v = Math.min(parseFloat(v), 2.0)
      dh = 0

      dh = (ch + wh)*v if dir is -1

      ch + dh + if v <= 1 then (wh - ch) * v else wh * v


    ###*
     * Generates css background path.
     * @param {string} url
     * @returns {string} css url path
     * @protected
    ###
    url: (url) ->
      "url(" + url + ")"

    ###*
     * Converts Number to Pixels.
     * @param {number} num
     * @returns {string} pixels
     * @protected
    ###
    px: (num) ->
      num + "px"

    ###*
    * Creates transform property.
    * @param {number} pos
    * @param {object} ctx
    * @returns {object} CSS transform
    * @protected
    ###
    transform: (pos, ctx) ->
      if isIE and ieVersion < 10
        {"transform": "translate(0," + pos + "px)"}
      else
        {
          "-webkit-transform": "translate3d(0," + pos + "px, 0)"
          "transform": "translate3d(0," + pos + "px, 0)"
          "transition": if isMobile then "" + ctx.options.duration + "ms" + " transform " + ctx.options.easing else "none"
        }

    ###*
     * Creates blur property
     * @param {number} blur
     * @returns {object} CSS blur
     * @protected
    ###
    blur: (blur) ->
      if blur > 3
        {'-webkit-filter': 'blur(' + blur + 'px)'
         ,'filter': 'blur(' + blur + 'px)'}
      else
        {'filter': 'none'
          ,'-webkit-filter': 'none'}

    ###*
    * Gets specific option of plugin
    * @protected
    ###
    getAttribute: (element, key)->
      if @.options.screenAliases?
        aliases = Object.keys(@.options.screenAliases).reverse()
        for i in [0..(aliases.length-1)]
          alias = if @.options.screenAliases[aliases[i]] isnt '' then "-#{@.options.screenAliases[aliases[i]]}" else @.options.screenAliases[aliases[i]]
          attr = element.getAttribute("data#{alias}-#{key}") 
          if aliases[i] <= @.$win.width() and attr?
            break;
      if attr?
        attr
      else
        @.options[key]







  ###*
   * The jQuery Plugin for the RD Parallax
   * @public
  ###
  $.fn.extend RDParallax: (options) ->
    @each ->
      $this = $(this)
      if !$this.data('RDParallax')
        $this.data 'RDParallax', new RDParallax(this, options)

  window.RDParallax = RDParallax
) window.jQuery, document, window


###*
 * The Plugin AMD export
 * @public
###
if module?
  module.exports = window.RDParallax
else if typeof define is 'function' && define.amd
  define(["jquery"], () ->
    'use strict'
    return window.RDParallax
  )