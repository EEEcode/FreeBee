#Requires AutoHotkey v2
#include OCR.ahk   ;https://github.com/Descolada/OCR

Esc:: ExitApp
^T:: reload


; Select Screen Region with Mouse
^#LButton:: ; Control+Win+Left Mouse to Select
{
	Area := SelectScreenRegion("LButton")
	Result := OCR.FromRect(Area.X, Area.Y, Area.W, Area.H)
	A_Clipboard := Result.Text
	;A_Clipboard := Result.Lines
	;MsgBox(Result.Text)
}

; Select Screen Region with Mouse
^#RButton:: ; Control+Win+Right Mouse to Select
{
	CoordMode "Mouse", "Screen"
	CoordMode "ToolTip", "Screen"

	Loop {
		MouseGetPos(&X, &Y)
		Highlight(x-75, y-25, 150, 50)
		ToolTip(OCR.FromRect(X-75, Y-25, 150, 50,,2).Text, , Y+40)
	}
}

Highlight(x?, y?, w?, h?, showTime:=0, color:="Red", d:=2) {
	static guis := []

	if !IsSet(x) {
        for _, r in guis
            r.Destroy()
        guis := []
		return
    }
    if !guis.Length {
        Loop 4
            guis.Push(Gui("+AlwaysOnTop -Caption +ToolWindow -DPIScale +E0x08000000"))
    }
	Loop 4 {
		i:=A_Index
		, x1:=(i=2 ? x+w : x-d)
		, y1:=(i=3 ? y+h : y-d)
		, w1:=(i=1 or i=3 ? w+2*d : d)
		, h1:=(i=2 or i=4 ? h+2*d : d)
		guis[i].BackColor := color
		guis[i].Show("NA x" . x1 . " y" . y1 . " w" . w1 . " h" . h1)
	}
	if showTime > 0 {
		Sleep(showTime)
		Highlight()
	} else if showTime < 0
		SetTimer(Highlight, -Abs(showTime))
}





SelectScreenRegion(Key, Color := "Lime", Transparent:= 80)
{
	CoordMode("Mouse", "Screen")
	MouseGetPos(&sX, &sY)
	ssrGui := Gui("+AlwaysOnTop -caption +Border +ToolWindow +LastFound -DPIScale")
	WinSetTransparent(Transparent)
	ssrGui.BackColor := Color
	Loop 
	{
		Sleep 10
		MouseGetPos(&eX, &eY)
		W := Abs(sX - eX), H := Abs(sY - eY)
		X := Min(sX, eX), Y := Min(sY, eY)
		ssrGui.Show("x" X " y" Y " w" W " h" H)
	} Until !GetKeyState(Key, "p")
	ssrGui.Destroy()
	Return { X: X, Y: Y, W: W, H: H, X2: X + W, Y2: Y + H }
}

