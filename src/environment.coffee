###
environment.coffee
Written by Seth Bullock
sedabull@gmail.com
###

#namespace object
@gh = Object.create(null)

#Greenhorn environment
env =
    #miscellaneous
    FRAME_RATE: 25
    BOUNCE_DECAY: 0
    SPRING_CONSTANT: 25
    #default engine settings
    ENGINE:
        footer: 'FOOTER'
        leftHeader: 'LEFT PANEL'
        rightHeader: 'RIGHT PANEL'
    #The Startup display
    STARTUP:
        size: 50
        color: '#006400'
        font: 'sans-serif'
        text: 'Click here to Start'
    #default Sprite settings
    IMAGE_PATH: "./"
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
        scale: 1
        width: 64
        height: 64
        visible: yes
        imageFile: ''
        highlight: false
        ba_top: 'WRAP'
        ba_bottom: 'WRAP'
        ba_right: 'WRAP'
        ba_left: 'WRAP'
    #default TEXTSPRITE settings
    TEXTSPRITE_DEFAULT_CONFIG:
        level: -1
        text: "*-TEXTSPRITE-*"
        fontSize: 12
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
        index: 1
        start: 1
        numFrames: 8
        name: 'UNDEFINED'
    ANISPRITE_DEFAULT_CONFIG:
        cellWidth: 32
        cellHeight: 32
        frameRate: 10
        orientation: 'horizontal'
    #default sound settings
    SOUND_PATH: "./"
    USE_AUDIO_TAG: false
    SOUND_DEFAULT_CONFIG:
        url: ""
        loop: false
        volume: 1.0
        autoplay: false
    #default button settings
    BUTTON_DEFAULT_CONFIG:
        type: 'button'
        onclick: undefined
        parent: 'rightPanel'
        label: 'Launch the Missiles!'
    #default timer settings
    TIMER_START_ON_CONSTRUCTION: yes

#add to namespace object
gh.env = env