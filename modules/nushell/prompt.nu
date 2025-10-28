let host_colors = {
    higashi: {start: "0xEC5228", end: "0xEF9651"},
    wolumonde: {start: "0x603F26", end: "0x6C4E31"},
    chernobog: {start: "0xA94438", end: "0xD24545"},
    "sd-148036": {start: "0x595CFF", end: "0xC6F8FF"},
    dzwonek: {start: "0x595CFF", end: "0xC6F8FF"},
    volsinii: {start: "0x595CFF", end: "0xC6F8FF"},
}
let user_colors = {
    kirara: {start: "0xFF407D", end: "0xEE99C2"},
    root: {start: "0xC5172E", end: "0xBF3131"},
    dusk: {start: "0x640D5F", end: "0xD91656"},
    dawn: {start: "0x640D5F", end: "0xD91656"},
    mayer: {start: "0x640D5F", end: "0xD91656"},
}

def create_left_prompt [] {
    let hostname = sys host | get hostname
    # str replace handles whoami output on windows
    let username = ^whoami | str replace $"($hostname)\\" ""

    let c = $host_colors | get $hostname
    let hostname_fmt = $hostname | ansi gradient --fgstart $c.start --fgend $c.end
    let c = $user_colors | get $username
    let username_fmt = $username | ansi gradient --fgstart $c.start --fgend $c.end

    let dir = match (do -i { $env.PWD | path relative-to $nu.home-path }) {
        null => $env.PWD
        '' => '~'
        $relative_pwd => ([~ $relative_pwd] | path join)
    }

    let separator_color = ansi light_cyan
    let string_color = ansi light_yellow
    $"($separator_color)//($hostname_fmt)($separator_color)/($username_fmt)($separator_color)/($string_color)cwd=\"($dir)\""
}

def create_right_prompt [] {
    ()
}

# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
# FIXME: This default is not implemented in rust code as of 2023-09-08.
$env.PROMPT_COMMAND_RIGHT = {|| create_right_prompt }

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "/ " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| "/: " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "/ " }
$env.PROMPT_MULTILINE_INDICATOR = {|| "/::: " }
