###
environment.coffee

The Greenhorn Gaming environment object
###

@env =
    #frame rate
    FRAME_RATE: 25
    #Greenhorn engine style
    ENGINE:
        accentColor: 'silver'
        backgroundColor: 'black'
        foregroundColor: 'darkgreen'
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
        align: "center"
        backgroundColor: "black"
        backgroundAlpha: 1.0
        backgroundVisible: yes
        borderSize: 5
        borderColor: "white"
        borderAlpha: 1.0
        borderVisible: yes
        fontName: "sans-serif"
        fontSize: 8
        fontColor: "white"
        fontAlpha: 1.0
        marginsTop: 5
        marginsBottom: 5
        marginsRight: 5
        marginsLeft: 5
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
        onclick: undefined
        parent: 'rightPanel'
        label: 'Launch the Missiles!'
        style:
            clear: 'left'
            cssFloat: 'left'
            width: '98%'
            color: 'black'
            margin: '1%'
            fontSize: 'small'
            backgroundColor: 'silver'
#end environment object

#the Greenhorn engine style object
_style =
    main:
        width: '74%'
        height: '60%'
        display: 'inline-block'
        marginTop: '5%'
        marginLeft: '13%'
        border: "5px solid #{env.ENGINE.accentColor}"
        borderRadius: '15px'
        fontFamily: 'Tahoma, Geneva, sans-serif'
        backgroundColor: env.ENGINE.foregroundColor
    title:
        width: '100%'
        textAlign: 'center'
        cssFloat: 'left'
        clear: 'both'
        display: 'initial'
        marginTop: '1%'
        marginBottom: '0px'
        paddingBottom: '1%'
        borderRadius: 'inherit'
        borderBottom: "1px solid #{env.ENGINE.accentColor}"
    panel:
        width: '15%'
        height: '78%'
        cssFloat: 'left'
        display: 'initial'
        margin: '1%'
        overflow: 'auto'
        whiteSpace: 'pre'
        fontSize: '.70em'
    panelHeader:
        textAlign: 'center'
        marginTop: '0'
        marginBottom: '5px'
        paddingBottom: '2px'
        borderBottom: "2px solid #{env.ENGINE.backgroundColor}"
    canvas:
        width: '65%'
        height: '78%'
        display: 'initial'
        cssFloat: 'left'
        borderRight: "1px solid #{env.ENGINE.accentColor}"
        borderLeft: "1px solid #{env.ENGINE.accentColor}"
        backgroundColor: env.ENGINE.backgroundColor
    footer:
        width: '100%'
        display: 'initial'
        textAlign: 'center'
        cssFloat: 'left'
        clear: 'both'
        paddingTop: '1%'
        marginBottom: '1%'
        borderRadius: 'inherit'
        borderTop: "1px solid #{env.ENGINE.accentColor}"
        fontSize: '1em'
#end _style object
