###
environment.coffee
Written by Seth Bullock
sedabull@gmail.com
###

@env =
    #frame rate
    FRAME_RATE: 25
    #Greenhorn engine style
    ENGINE:
        canvasWidth: 800
        canvasHeight: 450
        leftPanelWidth: 150
        rightPanelWidth: 150
        titleHeight: 50
        footerHeight: 25
        bounceDecay: 0
        accentColor: '#FFFFFF'
        backgroundColor: '#000000'
        foregroundColor: '#006400'
        footer: 'BOTTOM PANEL'
        leftHeader: 'LEFT PANEL'
        rightHeader: 'RIGHT PANEL'
    #The Startup display
    STARTUP:
        size: 50
        font: 'sans-serif'
        text: 'Click here to Start'
    #default Sprite settings
    IMAGE_PATH: ""
    SPRITE_DEFAULT_CONFIG:
        x: 0
        y: 0
        a: 0
        dx: 0
        dy: 0
        da: 0
        ddx: 0
        ddy: 0
        dda: 0
        level: 0
        width: 64
        height: 64
        visible: yes
        imageFile: ""
        boundAction: "WRAP"
    #default TextBox settings
    TEXTBOX_DEFAULT_CONFIG:
        level: -1
        text: "*-TextBox-*"
        fontSize: 8
        fontAlpha: 1.0
        fontColor: "white"
        fontAlign: "left"
        fontName: "sans-serif"
        borderSize: 5
        borderAlpha: 1.0
        borderVisible: yes
        borderColor: "white"
        outlineSize: 1
        outlineAlpha: 1.0
        outlineVisible: no
        outlineColor: "grey"
        marginsTop: 5
        marginsBottom: 5
        marginsRight: 5
        marginsLeft: 5
        backgroundAlpha: 1.0
        backgroundVisible: yes
        backgroundColor: "black"
    #default aniSprite settings
    ANICYCLE_DEFAULT_CONFIG:
        name: 'UNDEFINED'
        numFrames: 8
    ANISPRITE_DEFAULT_CONFIG:
        cellWidth: 32
        cellHeight: 32
        frameRate: 10
        orientation: 'horizontal'
    #default sound settings
    SOUND_PATH: ""
    USE_AUDIO_TAG: false
    SOUND_DEFAULT_CONFIG:
        url: ""
        loop: false
        volume: 1.0
        playOnLoad: false
    #default timer settings
    TIMER_START_ON_CONSTRUCTION: yes
    #default button settings
    BUTTON_DEFAULT_CONFIG:
        type: 'button'
        onclick: undefined
        parent: 'rightPanel'
        label: 'Launch the Missiles!'
        style:
            clear: 'left'
            cssFloat: 'left'
            width: '98%'
            margin: '1%'
            fontSize: 'small'
            color: '#FFFFFF'
            backgroundColor: '#000000'
#end environment object

#the Greenhorn engine style object
_style =
    main:
        margin: '2.5% auto'
        borderRadius: '15px'
        fontFamily: 'Tahoma, Geneva, sans-serif'
        color: env.ENGINE.accentColor
        backgroundColor: env.ENGINE.foregroundColor
        border: "5px solid #{env.ENGINE.accentColor}"
        minHeight: "#{env.ENGINE.canvasHeight + env.ENGINE.titleHeight + env.ENGINE.footerHeight + 40}px"
        minWidth: "#{env.ENGINE.canvasWidth + env.ENGINE.leftPanelWidth + env.ENGINE.rightPanelWidth + 40}px"
        maxHeight: "#{env.ENGINE.canvasHeight + env.ENGINE.titleHeight + env.ENGINE.footerHeight + 40}px"
        maxWidth: "#{env.ENGINE.canvasWidth + env.ENGINE.leftPanelWidth + env.ENGINE.rightPanelWidth + 40}px"
    title:
        width: '100%'
        margin: '0px'
        clear: 'both'
        cssFloat: 'left'
        marginTop: '10px'
        textAlign: 'center'
        paddingBottom: '9px'
        borderRadius: 'inherit'
        height: "#{env.ENGINE.titleHeight}px"
        borderBottom: "1px solid #{env.ENGINE.accentColor}"
    leftPanel:
        margin: '10px'
        cssFloat: 'left'
        overflow: 'auto'
        whiteSpace: 'pre'
        fontSize: '.70em'
        marginRight: '9px'
        width: "#{env.ENGINE.leftPanelWidth}px"
        height: "#{env.ENGINE.canvasHeight - 20}px"
    rightPanel:
        margin: '10px'
        cssFloat: 'left'
        overflow: 'auto'
        whiteSpace: 'pre'
        fontSize: '.70em'
        marginLeft: '9px'
        width: "#{env.ENGINE.rightPanelWidth}px"
        height: "#{env.ENGINE.canvasHeight - 20}px"
    panelHeader:
        marginTop: '0'
        textAlign: 'center'
        marginBottom: '5px'
        paddingBottom: '2px'
        borderBottom: "2px solid #{env.ENGINE.accentColor}"
    canvas:
        cssFloat: 'left'
        width: "#{env.ENGINE.canvasWidth}px"
        height: "#{env.ENGINE.canvasHeight}px"
        backgroundColor: env.ENGINE.backgroundColor
        borderLeft: "1px solid #{env.ENGINE.accentColor}"
        borderRight: "1px solid #{env.ENGINE.accentColor}"
    footer:
        width: '100%'
        clear: 'both'
        fontSize: '1em'
        cssFloat: 'left'
        paddingTop: '9px'
        textAlign: 'center'
        marginBottom: '10px'
        borderRadius: 'inherit'
        height: "#{env.ENGINE.footerHeight}px"
        borderTop: "1px solid #{env.ENGINE.accentColor}"
#end _style object
