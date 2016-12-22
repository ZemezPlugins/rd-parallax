###*
 * @module       RD Parallax
 * @author       Evgeniy Gusarov
 * @see          https://ua.linkedin.com/pub/evgeniy-gusarov/8a/a40/54a
 * @version      3.6.5
###
(($, document, window) ->
  ###*
   * Compatibility flags
  ###
  isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent)
  isChrome = /Chrome/.test(navigator.userAgent)
  isWebkit = (/Chrome/.test(navigator.userAgent) && /Google Inc/.test(navigator.vendor)) || (/Safari/.test(navigator.userAgent) && /Apple Computer/.test(navigator.vendor))
  isChromeIOS = isMobile and /crios/i.test(navigator.userAgent)
  isSafariIOS = /iPhone|iPad|iPod/i.test(navigator.userAgent) && !!navigator.userAgent.match(/Version\/[\d\.]+.*Safari/)
  isIE = navigator.appVersion.indexOf("MSIE") isnt -1 || navigator.appVersion.indexOf('Trident/') > -1
  isWin8 = /windows nt 6.2/.test(navigator.userAgent.toLowerCase()) || /windows nt 6.3/.test(navigator.userAgent.toLowerCase())
  hasClassList = document.body.classList?
  chromeVersion = if isChrome then navigator.userAgent.replace(/^.*Chrome\/([\d\.]+).*$/i, '$1') else false
  isChromeNew = chromeVersion >= '55.0.2883.75'

  ###*
   * The requestAnimationFrame polyfill
   * http://paulirish.com/2011/requestanimationframe-for-smart-animating/
  ###
  (()->
    lastTime = 0
    vendors = ['ms', 'moz', 'webkit', 'o']

    for vendor in vendors
      window.requestAnimationFrame = window["#{vendor}RequestAnimationFrame"]
      window.cancelAnimationFrame = window["#{vendor}CancelAnimationFrame"] || window["#{vendor}CancelRequestAnimationFrame"];

    if !window.requestAnimationFrame
      window.requestAnimationFrame = (callback, element)->
        currTime = new Date().getTime()
        timeToCall = Math.max(0, 16 - (currTime - lastTime))
        id = window.setTimeout(()->
          callback(currTime + timeToCall)
          return
        , timeToCall)
        lastTime = currTime + timeToCall
        return id

    if !window.cancelAnimationFrame
      window.cancelAnimationFrame = (id)->
        clearTimeout(id)
  )


  ###*
   * Creates a parallax.
   * @class RDParallax.
   * @public
   * @param {HTMLElement} element - The element to create the parallax for.
   * @param {Object} [options] - The options
  ###
  class RDParallax

    ###*
     * Creates a parallax layer.
     * @class Layer.
     * @public
     * @param {HTMLElement} element - The element to create a layer for.
     * @param {object} aliases - An object with width breakpoints aliases
     * @param {numbeer} windowWidth - current window width
    ###
    class Layer
      constructor: (element, aliases, windowWidth, windowHeight, sceneOffset, sceneHeight, sceneOn) ->
        # Value is using to amend scroll issues with fixed elements in webkit
        @.amend = if (isWebkit or isIE or isMobile) then (if isChromeNew then 0 else 60) else 0
        @.element = element
        @.aliases = aliases

        @.type = element.getAttribute("data-type") || "html"
        @.holder = @.createHolder() if @.type is "html"
        @.direction = if element.getAttribute("data-direction") is "normal" or !element.getAttribute("data-direction")? then 1 else -1
        @.fade = element.getAttribute("data-fade") is "true"
        @.blur = element.getAttribute("data-blur") is "true"
        @.boundTo = document.querySelector(element.getAttribute("data-bound-to"))
        @.url = element.getAttribute("data-url") if @.type is "media"
        @.responsive = @.getResponsiveOptions()

        # Use CSS Absolute for layer position if not IE
        if (!isIE and !isMobile) or  isMobile or (isWin8 and isIE)
          @.element.style["position"] = "absolute"
          # Use CSS Fixed && CSS Clip hack if IE
        else
          @.element.style["position"] = "fixed"

        switch @.type
          when "media"
            @.element.style["background-image"] = "url(#{@.url})" if @.url?
          when "html"
          # Push HTML layer to front for IE
            if isIE and isMobile
              @.element.style["z-index"] = 1

        @.refresh(windowWidth, windowHeight, sceneOffset, sceneHeight, sceneOn)
        return

      ###*
      * Refresh layer size statements
      * @param {number} window width
      * @public
      ###
      refresh: (windowWidth, windowHeight, sceneOffset, sceneHeight, sceneOn)->
        layer = @

        layer.speed = layer.getOption("speed", windowWidth) || 0
        layer.offset = layer.getOption("offset", windowWidth) || 0

        if !isMobile and !(isWin8 and isIE)
          if sceneOn
            layer.element.style["position"] = "fixed"
          else
            layer.element.style["position"] = "absolute"

        if isIE and layer.type is "html"
          layer.element.style["position"] = "absolute"

        switch layer.type
          when "media"
            if not isIE
              layer.offsetHeight = layer.getMediaHeight(windowHeight, sceneHeight, layer.speed, layer.direction)
              layer.element.style["height"] = "#{layer.offsetHeight}px"
          when "html"
            layer.element.style["width"] = "#{@.holder.offsetWidth}px"
            layer.offsetHeight = layer.element.offsetHeight
            layer.holder.style["height"] = "#{layer.offsetHeight}px"

            # Bound layer to holder by css absolute if not IE
            if (!isIE and !isMobile) or  isMobile or (isWin8 and isIE)
            else
              if isIE
                layer.element.style["position"] = "static"
              else if sceneOn
                layer.element.style["left"] = "#{layer.getOffset(layer.holder).left}px"
                layer.element.style["top"] = "#{layer.getOffset(layer.holder).top - sceneOffset}px"
              layer.holder.style["position"] = "static"
          when "custom"
            layer.offsetHeight = layer.element.offsetHeight

      ###*
      * Creates a static layer holder element
      * @public
      * @returns {element} holder
      ###
      createHolder: ()->
        layer = @
        holder = document.createElement("div")

        if hasClassList
          holder.classList.add("rd-parallax-layer-holder")
        else
          holder.className = "rd-parallax-layer-holder"

        layer.element.parentNode.insertBefore(holder, layer.element)
        holder.appendChild(layer.element)

        # Create relative holder if is not IE
        if (!isIE and !isMobile) or isChromeIOS
          holder.style["position"] = "relative"

        return holder

      ###*
      * Creates a static layer holder element
      * @public
      * @returns {element} holder
      ###
      isHolderWrong: ()->
        layer = @

        if layer.type is "html"
          if layer.holder.offsetHeight != layer.element.offsetHeight
            return true
        return false


      ###*
      * Gets specific option of layer
      * @public
      * @param {string} key
      * @param {number} window width
      * @returns {object} value
      ###
      getOption: (key, windowWidth)->
        layer = @
        for point of layer.responsive
          if point <= windowWidth then targetPoint = point
        return layer.responsive[targetPoint][key]

      ###*
      * Creates a set of responsive options of the layer
      * @public
      * @returns {object} options
      ###
      getResponsiveOptions: ()->
        responsive = {}
        resolutions = []
        aliases = []

        for i, alias of @.aliases
          resolutions.push(i)
          aliases.push(alias)

        for point, i in resolutions
          responsive[point] = {}

          while (j = i) >= -1
            if !responsive[point]["speed"] and (value = @.element.getAttribute("data#{aliases[j]}speed"))
              responsive[point]["speed"] = @.getSpeed(value)

            if !responsive[point]["offset"] and (value = @.element.getAttribute("data#{aliases[j]}offset"))
              responsive[point]["offset"] = parseInt(value)

            if !responsive[point]["fade"] and (value = @.element.getAttribute("data#{aliases[j]}fade"))
              responsive[point]["fade"] = value is 'true'

            i--

        return responsive

      ###*
      * Fade layer according to its position in scene
      * @public
      * @param {number} sceneOffset - current scene offset
      * @param {number} sceneHeight - current scene height
      ###
      fuse: (sceneOffset, sceneHeight)->
        layer = @

        offsetTop = layer.getOffset(layer.element).top + layer.element.getBoundingClientRect().top

        sceneDevider = sceneOffset + sceneHeight / 2.0
        layerDevider = offsetTop + layer.offsetHeight / 2.0
        pos = sceneHeight / 6.0

        if sceneDevider + pos > layerDevider and sceneDevider - pos < layerDevider
          layer.element.style["opacity"] = 1
        else
          if sceneDevider - pos < layerDevider
            opacity = 1 + ((sceneDevider + pos - layerDevider) / sceneHeight / 3.0 * 10)
          else
            opacity = 1 - ((sceneDevider - pos - layerDevider) / sceneHeight / 3.0 * 10)

          layer.element.style["opacity"] = if opacity < 0 then 0 else if opacity > 1 then 1 else opacity.toFixed(2)


        return

      ###*
      * Move layer in scene
      * @public
      * @param {number} scrollY - current scroll top
      * @param {number} windowWidth - current window width
      * @param {number} windowHeight - current window height
      * @param {number} sceneOffset - current scene offset top
      * @param {number} sceneHeight - current scene height
      * @param {number} documentHeight - current scene height
      * @param {number} agentOffset - current agent offset
      ###
      move: (scrollY, windowWidth, windowHeight, sceneOffset, sceneHeight, documentHeight, sceneOn, agentOffset, inputFocus)->
        layer = @

        # Disable moving in IE for media layers
        return if isIE and layer.type is "media"
        # Disable moving in Chrome on Mobile Devices
        return if isMobile or (isWin8 and isIE)

        if !sceneOn
          if isWebkit
            layer.element.style["-webkit-transform"] = "translate3d(0,0,0)"
          layer.element.style["transform"] = "translate3d(0,0,0)"
          return

        # Calculate speed by absolute position if not IE
        if (!isMobile) or (layer.type is "html" and inputFocus) or isChromeIOS
          v = layer.speed * layer.direction
          # Calculate speed by fixed position for IE
        else
          v = layer.speed * layer.direction - 1

        h = layer.offsetHeight

        # Agent layer position correction
        if agentOffset?
          dy = (sceneOffset + windowHeight - (agentOffset + windowHeight)) / (windowHeight - sceneHeight)
          # Else calc with document agent
        else if layer.type isnt "media"
          if sceneOffset < windowHeight or sceneOffset > documentHeight - windowHeight
            # First Screen layer position correction
            if sceneOffset < windowHeight
              dy = sceneOffset / (windowHeight - sceneHeight)

              # Last Screen layer position correction
            else
              dy = (sceneOffset + windowHeight - documentHeight ) / (windowHeight - sceneHeight)

            # Set Layer position correction to zero if is NaN
            if !isFinite(dy)
              dy = 0
          else
            dy = 0.5
        else
          dy = 0.5

        # Disable Layer scrolling in iOS Chrome and IE
        if isChromeIOS or isIE
          pos = (sceneHeight - h) / 2 + (windowHeight - sceneHeight)*dy*v + layer.offset
        else if isMobile
          pos = -(sceneOffset - scrollY) * v + (sceneHeight - h) / 2 + (windowHeight - sceneHeight)*dy*(v + 1) + layer.offset
        else
          pos = -(sceneOffset - scrollY) * v + (sceneHeight - h) / 2 + (windowHeight - sceneHeight)*dy*v + layer.offset

        if isMobile
          if agentOffset?
            layer.element.style["top"] = "#{sceneOffset - agentOffset}px"

        #        if isSafariIOS
        #          if inputFocus
        #            pos += sceneOffset

        # Set vendor for old safari and chrome
        if isWebkit
          @.element.style["-webkit-transform"] = "translate3d(0,#{pos}px,0)"
        @.element.style["transform"] = "translate3d(0,#{pos}px,0)"

        return

      ###*
      * Normalize layer speed
      * @public
      * @param {number} value - speed
      * @returns {number} normalized speed
      ###
      getSpeed: (value)->
        return Math.min(Math.max(parseFloat(value), 0), 2.0)

      ###*
      * Calculate media layer height
      * @public
      * @param {number} windowHeight - current window height
      * @param {number} sceneHeight - current scene height
      * @param {number} speed - current speed
      * @param {number} direction - movement direction
      * @returns {number} media layer height
      ###
      getMediaHeight: (windowHeight, sceneHeight, speed, direction)->
        directionModifier = if direction is -1 then (sceneHeight + windowHeight) * speed else 0

        return (sceneHeight + directionModifier + if speed <= 1 then Math.abs(windowHeight - sceneHeight) * speed else windowHeight * speed) + @.amend*2

      ###*
       * Calc the element offset relative to document. Method is similar to $.offset()
       * @public
       * @param {element} element - HTML Element
       * @returns {object} top and left offsets
      ###
      getOffset: (element)->
        bound = element.getBoundingClientRect()
        left = bound.left + (window.scrollX || window.pageXOffset)
        top = bound.top + (window.scrollY || window.pageYOffset)

        return {top: top, left: left}

    ###*
     * Creates a parallax scene.
     * @class Scene.
     * @public
     * @param {HTMLElement} element - The element to create a scene for.
     * @param {object} aliases - An object with width breakpoints aliases
     * @param {numbeer} windowWidth - current window width
    ###
    class Scene
      constructor: (element, aliases, windowWidth, windowHeight) ->
        scene = @

        # Value is using to amend scroll issues with fixed elements in webkit
        scene.amend = if isWebkit and !isChromeNew then 60 else 0
        scene.element = element
        scene.aliases = aliases

        scene.on = true
        scene.agent = document.querySelector(element.getAttribute("data-agent"))
        scene.anchor = scene.findAnchor()
        scene.canvas = scene.createCanvas()
        scene.layers = scene.createLayers(windowWidth)
        scene.fitTo = scene.getFitElement()
        scene.responsive = scene.getResponsiveOptions()

        scene.refresh(windowWidth, windowHeight)

      ###*
       * Finds an element that layer will fit to
       * @public
       * @returns {element} fit element
      ###
      getFitElement: ()->
        scene = @

        if (fitTo = scene.element.getAttribute("data-fit-to"))?
          if fitTo is "parent"
            return scene.element.parentNode
          else
            return document.querySelector(fitTo)
        else
          return null

      ###*
       * Checks if parallax scene is inside of element with CSS Transform
       * @public
       * @returns {element} Parent element with CSS Transform or null
      ###
      findAnchor: ()->
        scene = @

        parent = scene.element.parentNode
        while parent? and parent isnt document
          if scene.isTransformed.call(parent)
            return parent
          parent = parent.parentNode

        return null

      ###*
       * Creates a parallax canvas element
       * @public
       * @returns {element} canvas
      ###
      createCanvas: ()->
        scene = @
        canvas = document.createElement("div")

        if hasClassList
          canvas.classList.add("rd-parallax-inner")
        else
          canvas.className = "rd-parallax-inner"

        scene.element.appendChild(canvas)

        while scene.element.firstChild isnt canvas
          canvas.appendChild(scene.element.firstChild)

        scene.element.style["position"] = "relative"
        scene.element.style["overflow"] = "hidden"

        # Use CSS Fixed to create canvas if is not IE or not mobile
        if !isIE and !isMobile
          canvas.style["position"] = "fixed"
          # Use CSS Clip hack for ie and mobile
        else
          canvas.style["position"] = "absolute"
          if not (isWin8 and isIE)
            canvas.style["clip"] = "rect(0, auto, auto, 0)"

          # Fix IE input pointer issue inside CSS Clip
          if isIE
            canvas.style["transform"] = "translate3d(0,0,0)"
          else
            canvas.style["transform"] = "none"


        canvas.style["left"] = "#{scene.offsetLeft}px"
        canvas.style["top"] = 0

        if isWebkit
          canvas.style["margin-top"] = "-#{scene.amend}px"
          canvas.style["padding"] = "#{scene.amend}px 0"
          scene.element.style["z-index"] = 0

        return canvas

      ###*
      * Gets specific option of layer
      * @public
      * @param {string} key
      * @param {number} window width
      * @returns {object} value
      ###
      getOption: (key, windowWidth)->
        for point of @.responsive
          if point <= windowWidth then targetPoint = point
        return @.responsive[targetPoint][key]

      ###*
       * Creates a set of responsive options of the layer
       * @public
       * @returns {object} options
      ###
      getResponsiveOptions: ()->
        responsive = {}
        resolutions = []
        aliases = []

        for i, alias of @.aliases
          resolutions.push(i)
          aliases.push(alias)

        for point, i in resolutions
          responsive[point] = {}

          while (j = i) >= -1
            if !responsive[point]["on"] and (value = @.element.getAttribute("data#{aliases[j]}on"))?
              responsive[point]["on"] = value isnt "false"

            if !responsive[point]["on"]? and j is 0
              responsive[point]["on"] = true

            i--
        return responsive

      ###*
       * Creates the layers of parallax
       * @public
       * @param {number} window width
       * @returns {array} List of layers
      ###
      createLayers: (windowWidth, windowHeight)->
        scene = @
        elements = $(scene.element).find(".rd-parallax-layer").get() # TODO: Replace with native js
        layers = []

        for element, i in elements
          layers.push(new Layer(element, scene.aliases, windowWidth, windowHeight, scene.offsetTop, scene.offsetHeight, scene.on))

        return layers

      ###*
       * Update scene position
       * @public
      ###
      move: (scrollY)->
        scene = @
        if scene.anchor?
          pos = scene.positionTop
        else
          pos = scene.offsetTop - scrollY

        # Set vendor for old safari and chrome
        if isWebkit
          scene.canvas.style["-webkit-transform"] = "translate3d(0,#{pos}px,0)"
        scene.canvas.style["transform"] = "translate3d(0,#{pos}px,0)"

      ###*
       * Refresh scene dimensions
       * @param {number} windowWidth - current window width
       * @param {number} windowHeight - current window height
       * @public
      ###
      refresh: (windowWidth, windowHeight)->
        scene = @
        mediaLayers = []

        scene.on = scene.getOption("on", windowWidth)
        scene.offsetTop = scene.getOffset(scene.element).top
        scene.offsetLeft = scene.getOffset(scene.element).left
        scene.width = scene.element.offsetWidth
        scene.canvas.style["width"] = "#{scene.width}px"

        # Calculate relative offset to parent with CSS Transform
        if scene.anchor?
          scene.positionTop = scene.element.offsetTop

        # Calculate Agent offset
        if scene.agent?
          scene.agentOffset = scene.getOffset(scene.agent).top
          scene.agentHeight = scene.agent.offsetHeight
        else
          scene.agentOffset = scene.agentHeight = null

        # Update all scene layers except medias
        for layer in scene.layers
          if layer.type is "media"
            mediaLayers.push(layer)
          else
            layer.refresh(windowWidth, windowHeight, scene.offsetTop, scene.offsetHeight, scene.on)

        scene.offsetHeight = scene.canvas.offsetHeight - scene.amend*2
        scene.element.style["height"] = "#{scene.offsetHeight}px"

        # Update media layers when scene height was recalcucated
        for layer in mediaLayers

          layer.refresh(windowWidth, windowHeight, scene.offsetTop, scene.offsetHeight, scene.on)

        return

      ###*
       * Update scene act
       * @public
      ###
      update: (scrollY, windowWidth, windowHeight, documentHeight, inputFocus)->
        scene = @

        sceneOffset = scene.offsetTop
        sceneHeight = scene.offsetHeight

        if !isIE and (!isMobile)
          scene.move(scrollY)

        # Check if layers are in viewport
        #        if (scrollY + windowHeight >= sceneOffset and scrollY <= sceneOffset + sceneHeight)
        for layer in scene.layers
          layer.move(scrollY, windowWidth, windowHeight, sceneOffset, sceneHeight, documentHeight, scene.on, scene.agentOffset, inputFocus)
          layer.fade = layer.getOption("fade", windowWidth) || false
          layer.fuse(sceneOffset, sceneHeight) if layer.fade and !isMobile and !isIE

      ###*
       * Checks if element is transformed
       * @public
       * @returns {boolean}
      ###
      isTransformed: ()->
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
              transformed = window.getComputedStyle(el).getPropertyValue(transforms[t])

        if (transformed? and transformed.length > 0 and transformed isnt "none")
          return true
        else
          return false

      ###*
       * Calc the element offset relative to document. Method is similar to $.offset()
       * @public
       * @param {element} element - HTML Element
       * @returns {object} top and left offsets
      ###
      getOffset: (element)->
        bound = element.getBoundingClientRect()
        left = bound.left + (window.scrollX || window.pageYOffset)
        top = bound.top + (window.scrollY || window.pageYOffset)

        return {top: top, left: left}

    ###*
     * Default options for parallax.
     * @public
    ###
    Defaults:
      selector: '.rd-parallax'
      screenAliases: {
        0: '-'
        480: '-xs-'
        768: '-sm-'
        992: '-md-'
        1200: '-lg-'
        1920: '-xl-'
        2560: '-xxl-'
      }

    constructor: (options) ->
      @.options = $.extend(true, {}, @.Defaults, options)
      @.scenes = []
      @.initialize()
      @.scrollY = window.scrollY || window.pageYOffset
      @.lastScrollY = -1
      @.lastDocHeight = 0
      @.inputFocus = false
      @.checkLayerHeight = false

    ###*
     * Initializes the Parallax.
     * @public
    ###
    initialize: () ->
      ctx = @
      elements = document.querySelectorAll(ctx.options.selector)
      windowWidth = window.innerWidth
      windowHeight = window.innerHeight

      for element, i in elements
        ctx.scenes.push(new Scene(element, ctx.options.screenAliases, windowWidth, windowHeight))

      $(window).on("resize", $.proxy(ctx.resize, ctx))

      # Fix default scrolling in iOS Safari on input focus
      if isSafariIOS
        $('input').on("focusin focus", (e)->
          e.preventDefault()
          ctx.activeOffset = $(@).offset().top
          window.scrollTo(window.scrollX || window.pageXOffset, ctx.activeOffset - this.offsetHeight - 100)
        )

      $(window).trigger("resize")
      ctx.update()
      ctx.checkResize()
      return

    ###*
     * Resize all scenes
     * @public
    ###
    resize: (forceResize)->
      ctx = @
      if ((currentWindowWidth = window.innerWidth) isnt ctx.windowWidth or !isMobile or forceResize)
        ctx.windowWidth = currentWindowWidth
        ctx.windowHeight = window.innerHeight
        ctx.documentHeight = document.body.offsetHeight

        for scene in ctx.scenes
          scene.refresh(ctx.windowWidth, ctx.windowHeight)

        ctx.update(true)

    ###*
     * Update all parallax scenes
     * @param {boolean} forceUpdate - force scenes update if scroll wasnt triggered
     * @public
    ###
    update: (forceUpdate)->
      ctx = @

      if !forceUpdate
        requestAnimationFrame(()->
          ctx.update()
          return
        )

      scrollY = window.scrollY || window.pageYOffset

      # Fix parallax crash on input focus in Safari iOS
      if isSafariIOS
        if (activeElement = document.activeElement)?
          if activeElement.tagName.match(/(input)|(select)|(textarea)/i)
            ctx.activeElement = activeElement
            ctx.inputFocus = true
          else
            ctx.activeElement = null
            ctx.inputFocus = false
            forceUpdate = true

      # Fix Mobile Chrome status bar resizing the page
      if isMobile and isChrome
        deltaHeight = window.innerHeight - ctx.windowHeight
        ctx.deltaHeight = deltaHeight
        scrollY -= ctx.deltaHeight

      # Update All Parallax scenes
      if ((scrollY isnt ctx.lastScrollY) or forceUpdate) and !ctx.isActing
        ctx.isActing = true


        windowWidth = ctx.windowWidth
        windowHeight = ctx.windowHeight
        documentHeight = ctx.documentHeight

        deltaScroll = scrollY - ctx.lastScrollY

        # Fix iOS Safari input cursor position issue
        if isSafariIOS
          if ctx.activeElement?
            ctx.activeElement.value = ctx.activeElement.value + " "
            ctx.activeElement.value = ctx.activeElement.value.trim()


        for scene in ctx.scenes
          if ctx.inputFocus || forceUpdate ||  (scrollY + windowHeight >= (scene.agentOffset || scene.offsetTop) + deltaScroll  and scrollY <= (scene.agentOffset || scene.offsetTop) + (scene.agentHeight || scene.offsetHeight) + deltaScroll)
            scene.update(scrollY, windowWidth, windowHeight, documentHeight, ctx.inputFocus)

        ctx.lastScrollY = scrollY
        ctx.isActing = false

    checkResize:() ->
      ctx = @

      setInterval(->
        docHeight = document.body.offsetHeight
        for scene in ctx.scenes
          for layer in scene.layers
            if layer.isHolderWrong()
              ctx.checkLayerHeight = true
              break
          if ctx.checkLayerHeight then break

        if ctx.checkLayerHeight or docHeight isnt ctx.lastDocHeight
          ctx.resize(true)
          ctx.lastDocHeight = docHeight
          ctx.checkLayerHeight = false
      , 500)
      return



  ###*
   * The jQuery Plugin for the RD Parallax
   * @public
  ###
  $.RDParallax = (options) ->
    $doc = $(document)
    if !$doc.data('RDParallax')
      $doc.data 'RDParallax', new RDParallax(options)

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