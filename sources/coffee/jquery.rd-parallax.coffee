###*
 * @module       RD Parallax
 * @author       Evgeniy Gusarov
 * @see          https://ua.linkedin.com/pub/evgeniy-gusarov/8a/a40/54a
 * @version      3.2.1
###
(($, document, window) ->
  ###*
   * Initial flags
   * @public
  ###
  isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
  isSafariIOS = /iPhone|iPad|iPod/i.test(navigator.userAgent) && !!navigator.userAgent.match(/Version\/[\d\.]+.*Safari/)
  isIE = navigator.appVersion.indexOf("MSIE") isnt -1 || navigator.appVersion.indexOf('Trident/') > 0

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
      direction: 'normal'
      speed: 1
      offset: 0
      screenAliases: {
        0: ''
        480: 'xs'
        768: 'sm'
        992: 'md'
        1200: 'lg'
        1920: 'xl'
        2560: 'xxl'
      }

    constructor: (element, options) ->
      @.options = $.extend(true, {}, @.Defaults, options)
      @.$element = $(element)
      @.$canvas = false
      @.$win = $(window)
      @.$doc = $(document)
      @.$anchor = false
      @.initialize()

    ###*
     * Initializes the Parallax.
     * @protected
    ###
    initialize: () ->
      ctx = @

      ctx
      .$element
      .parents()
      .each(()->
        # Check if parallax canvas is inside of transformed element
        el = @
        transforms = {
          'webkitTransform':'-webkit-transform'
          'OTransform':'-o-transform'
          'msTransform':'-ms-transform'
          'MozTransform':'-moz-transform'
          'transform':'transform'
        }

        for t of transforms
          if transforms.hasOwnProperty(t)
            if el.style[t]?
              hasMatrix = window.getComputedStyle(el).getPropertyValue(transforms[t])

        if (hasMatrix? and hasMatrix.length > 0 and hasMatrix isnt "none")
          ctx.$anchor = $(@)
          return false
      )
      .end()
      .wrapInner($('<div/>', {"class": "rd-parallax-inner"}))
      .find(".rd-parallax-layer[data-type]")
      .each ->
        layer = $(@)

        switch layer.attr("data-type").toLowerCase()
          when "media"
            # Build Image media
            if url = @.getAttribute("data-url")
              layer.css({
                "background-image": ctx.url(url)
              })

              # Create Media Blur handler
              if @.getAttribute("data-blur") == "true" or ctx.options.blur
                $('<img/>', {src: url}).load(() ->
                  # Save image original size
                  layer.attr("data-media-width", this.width)
                  layer.attr("data-media-height", this.height)

                  # Create media listener on blur image if its to small
                  ctx.$win.on("resize", $.proxy(ctx.blurMedia, layer[0], ctx)) if !isMobile

                  # Make image initial blur if needed
                  $.proxy(ctx.blurMedia, layer[0], ctx)()
                )

            ctx.$element.on("resize", $.proxy(ctx.resizeMedia, @, ctx))
            ctx.$element.on("resize", $.proxy(ctx.moveLayer, @, ctx))

            # Create media resize handlers
            if !isMobile
              ctx.$win.on("resize", $.proxy(ctx.resizeMedia, @, ctx))
            else
              ctx.$win.on("orientationchange", $.proxy(ctx.resizeMedia, @, ctx))

        # Apply layer handlers
        if !isMobile
          ctx.$doc.on("scroll", $.proxy(ctx.moveLayer, @, ctx))
          ctx.$win.on("resize", $.proxy(ctx.moveLayer, @, ctx))

          # Create Layer fade handler
          if @.getAttribute("data-fade") == "true"
            # Fade layer on scroll
            ctx.$doc.on("scroll", $.proxy(ctx.fadeLayer, @, ctx))

            # Fade layer on window resize on desktop
            ctx.$win.on("resize", $.proxy(ctx.fadeLayer, @, ctx))

        # Create move handler for device fallback
        else
          ctx.$win.on("resize orientationchange", $.proxy(ctx.moveLayer, @, ctx))

        return

      ctx.$canvas = ctx.$element.find(".rd-parallax-inner")

      if (ctx.$element.attr("data-fit-to-parent") is "true")
        ctx.$win.on("resize", $.proxy(ctx.fitCanvas, ctx.$canvas, ctx))

      # Create fixed Canvas to prevent lagging on desktop
      if !isMobile
        ctx.$win.on("resize", $.proxy(ctx.resizeWrap, ctx.$element[0], ctx))
        ctx.$win.on("resize", $.proxy(ctx.resizeCanvas, ctx.$canvas[0], ctx))
        ctx.$doc.on("scroll", $.proxy(ctx.moveCanvas, ctx.$canvas[0], ctx))
        ctx.$win.on("resize", $.proxy(ctx.moveCanvas, ctx.$canvas[0], ctx))

      # Trigger Initial Events
      ctx.$win.trigger("resize")
      ctx.$win.trigger("orientationchange")
      ctx.$doc.trigger("scroll")

      ctx.$win.load(()->
        ctx.$win.trigger("resize")
        ctx.$win.trigger("orientationchange")
        ctx.$doc.trigger("scroll")
      )

      return


    ###*
     * Moves Layer
     * @param {object} ctx
     * @protected
    ###
    moveLayer: (ctx) ->
      # Dont move if parallax is disabled
      if (sceneOn = ctx.getAttribute(ctx.$element[0], 'on'))?
        if sceneOn isnt "true"
          $(@).css({"-webkit-transform": "none", "transform": "none"})
          return  

      scrt = ctx.$win.scrollTop()
      offt = ctx.$element.offset().top
      wh = ctx.$win.height()
      ch = ctx.$element.height()
      dh = ctx.$doc.height()
      h = @.offsetHeight
      v = Math.max(parseFloat(v), 0)
      dir = if ctx.getAttribute(@, 'direction') is "inverse" then -1 else 1
      v = dir * Math.min(parseFloat(ctx.getAttribute(@, 'speed')), 2.0)
      agent = @.getAttribute("data-agent")

      # If agent is set
      if (agent = @.getAttribute("data-agent"))?
        # Agent layer position correction
        if (agent = $(agent)).length
          dy = (offt + wh - (agent.offset().top + wh)) / (wh - ch)
        else
          dy = 0.5

      # Else calc with document agent
      else if @.getAttribute("data-type") isnt "media"
        if offt < wh or offt > dh - wh
          # First Screen layer position correction
          if offt < wh
            dy = offt / (wh - ch)

          # Last Screen layer position correction
          else
            dy = (offt + wh - dh ) / (wh - ch)

          # Set Layer position correction to zero if is NaN
          if !isFinite(dy)
            dy = 0
        else
          dy = 0.5
      else
        dy = 0.5




      # Move layer on Desktop
      if !isMobile
        pos = -(offt - scrt) * v + (ch - h) / 2 + (wh - ch)*dy*v + parseInt(ctx.getAttribute(@, 'offset'))

        # Check layers is in viewport
        if (scrt + wh >= offt and scrt <= offt + ch) or @.getAttribute("data-unbound") is "true"
          $(@).css(ctx.transform(pos, ctx))

      # Send layer to scene center of devices
      else
        pos = (ch - h) / 2
        $(@).css(ctx.transform(pos, ctx))



    ###*
     * Move Canvas
     * @param {object} ctx
     * @protected
    ###
    moveCanvas: (ctx, e)->
      canvas = $(@)
      scrt = ctx.$win.scrollTop()
      offt = ctx.$element.offset().top

      pos = (if ctx.$anchor then ctx.$element.position().top else offt - scrt)

      canvas
        .css({"top": pos})

    ###*
     * Fade Layer
     * @param {object} ctx
     * @protected
    ###
    fadeLayer: (ctx, e) ->
      layer = $(@)
      ch = ctx.$element.height()
      coff = ctx.$element.offset().top + ch / 2
      loff = layer.offset().top + layer.height() / 2
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
     * Resize Main parallax wrap
     * @param {object} ctx
     * @protected
    ###
    resizeWrap: (ctx) ->
      @.style.height = ctx.px(ctx.$canvas.outerHeight())


    ###*
     * Resize Canvas
     * @param {object} ctx
     * @protected
    ###
    resizeCanvas: (ctx) ->
      $canvas = $(@)
      $canvas.css({
        "position": if isIE && ctx.$anchor then "relative" else "fixed"
        "left": (if isIE then "auto" else (if ctx.$anchor then ctx.$element.offset().left - ctx.$anchor.offset().left else ctx.$element.offset().left))
        "width": ctx.$element.width()
      })

    fitCanvas: (ctx)->
      setTimeout(()->
        ctx.$canvas.css({"height": ctx.$element.parent().parent().height()})
      )


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
      dh = if dir is -1 then (ch + wh) * v else 0

      (ch + dh + if v <= 1 then Math.abs(wh - ch) * v else wh * v) + 56


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
      {
        "-webkit-transform": "matrix3d(1,0,0.00,0,0.00,1,0.00,0,0,0,1,0,0," + pos + ",0,1)"
        "transform": "matrix3d(1,0,0.00,0,0.00,1,0.00,0,0,0,1,0,0," + pos + ",0,1)"
      }

    ###*
     * Creates blur property
     * @param {number} blur
     * @returns {object} CSS blur
     * @protected
    ###
    blur: (blur) ->
      if blur > 3
        {
          '-webkit-filter': 'blur(' + blur + 'px)'
          , 'filter': 'blur(' + blur + 'px)'
        }
      else
        {
          'filter': 'none'
          , '-webkit-filter': 'none'
        }

    ###*
    * Gets specific option of plugin
    * @protected
    ###
    getAttribute: (element, key)->
      if @.options.screenAliases?
        aliases = Object.keys(@.options.screenAliases).reverse()
        for i in [0..(aliases.length - 1)]
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

  window.RDParallax = RDParallax) window.jQuery, document, window


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