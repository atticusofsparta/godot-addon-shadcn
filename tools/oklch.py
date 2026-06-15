import math

def oklch_to_srgb(L, C, h_deg, alpha=1.0):
    h = math.radians(h_deg)
    a = C * math.cos(h); b = C * math.sin(h)
    l_ = L + 0.3963377774 * a + 0.2158037573 * b
    m_ = L - 0.1055613458 * a - 0.0638541728 * b
    s_ = L - 0.0894841775 * a - 1.2914855480 * b
    l = l_**3; m = m_**3; s = s_**3
    r = +4.0767416621*l - 3.3077115913*m + 0.2309699292*s
    g = -1.2684380046*l + 2.6097574011*m - 0.3413193965*s
    bb= -0.0041960863*l - 0.7034186147*m + 1.7076147010*s
    def gamma(x):
        x = max(0.0, min(1.0, x))
        return 12.92*x if x <= 0.0031308 else 1.055*(x**(1/2.4)) - 0.055
    return tuple(round(gamma(v),5) for v in (r,g,bb)) + (round(alpha,5),)

def hexc(t):
    return "#" + "".join(f"{round(c*255):02x}" for c in t[:3]) + (f"{round(t[3]*255):02x}" if t[3]<1 else "")

# token: (L, C, h, alpha)
def parse(s):
    s=s.strip()
    if s.startswith("oklch("): s=s[6:-1]
    parts=s.replace("/"," ").split()
    L=float(parts[0].replace('%',''))/(100 if '%' in parts[0] else 1)
    C=float(parts[1]); h=float(parts[2]) if len(parts)>2 and parts[2] not in ('',) else 0.0
    a=1.0
    if '%' in s.split('/')[-1] and '/' in s:
        a=float(s.split('/')[-1].strip().replace('%',''))/100
    return oklch_to_srgb(L,C,h,a)

LIGHT={
"background":"1 0 0","foreground":"0% 0 0","card":"1 0 0","card-foreground":"0% 0 0",
"popover":"1 0 0","popover-foreground":"0% 0 0","primary":"0% 0 0","primary-foreground":"0.985 0 0",
"secondary":"0.97 0 0","secondary-foreground":"0.205 0 0","muted":"0.97 0 0","muted-foreground":"0.556 0 0",
"accent":"0.97 0 0","accent-foreground":"0.205 0 0","destructive":"0.577 0.245 27.325","destructive-foreground":"0.97 0.01 17",
"border":"0.922 0 0","input":"0.922 0 0","ring":"0.708 0 0","surface":"0.98 0 0","selection":"0% 0 0","selection-foreground":"1 0 0",
}
DARK={
"background":"0.145 0 0","foreground":"0.985 0 0","card":"0.205 0 0","card-foreground":"0.985 0 0",
"popover":"0.205 0 0","popover-foreground":"0.985 0 0","primary":"0.922 0 0","primary-foreground":"0.205 0 0",
"secondary":"0.269 0 0","secondary-foreground":"0.985 0 0","muted":"0.269 0 0","muted-foreground":"0.708 0 0",
"accent":"0.371 0 0","accent-foreground":"0.985 0 0","destructive":"0.704 0.191 22.216","destructive-foreground":"0.58 0.22 27",
"border":"1 0 0 / 10%","input":"1 0 0 / 15%","ring":"0.556 0 0","surface":"0.2 0 0","selection":"0.922 0 0","selection-foreground":"0.205 0 0",
}
if __name__ == "__main__":
    for name,d in (("LIGHT",LIGHT),("DARK",DARK)):
        print(f"--- {name} ---")
        for k,v in d.items():
            print(f"{k:24s} {hexc(parse(v))}")
