struct Theme {
    let background: String
    let backgroundDark: String
    let foreground: String
    let foregroundDim: String
    let accent: String
    let accentSecondary: String
    
    static var current: Theme {
        return Theme(
            background: "#26272C",
            backgroundDark: "#222227",
            foreground: "#D8DCF1",
            foregroundDim: "#8D93B4",
            accent: "#586AC9",
            accentSecondary: "#C9A958"
        )
    }
}
