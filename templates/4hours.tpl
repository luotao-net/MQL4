<chart>
id=130622296378465009
symbol=AUDUSD
period=240
leftpos=2058
digits=5
scale=8
graph=1
fore=0
grid=0
volume=0
scroll=0
shift=1
ohlc=1
one_click=0
askline=0
days=1
descriptions=0
shift_size=20
fixed_pos=0
window_left=125
window_top=125
window_right=1226
window_bottom=562
window_type=3
background_color=0
foreground_color=16777215
barup_color=9639167
bardown_color=16760576
bullcandle_color=9639167
bearcandle_color=16760576
chartline_color=65280
volumes_color=3329330
grid_color=10061943
askline_color=255
stops_color=255

<window>
height=184
fixed_height=0
<indicator>
name=main
</indicator>
<indicator>
name=Moving Average
period=365
shift=0
method=1
apply=0
color=3329330
style=1
weight=1
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=200
shift=0
method=0
apply=0
color=16711680
style=0
weight=3
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=89
shift=0
method=0
apply=0
color=3937500
style=0
weight=2
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=21
shift=0
method=1
apply=0
color=13828244
style=0
weight=2
period_flags=0
show_data=1
</indicator>
<indicator>
name=Moving Average
period=8
shift=0
method=1
apply=0
color=32896
style=0
weight=1
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=29
fixed_height=0
<indicator>
name=Custom Indicator
<expert>
name=RSI_Color
flags=339
window_num=1
<inputs>
InpRSIPeriod=14
</inputs>
</expert>
shift_0=0
draw_0=0
color_0=16777215
style_0=0
weight_0=0
shift_1=0
draw_1=0
color_1=255
style_1=0
weight_1=0
shift_2=0
draw_2=0
color_2=65280
style_2=0
weight_2=0
min=0.000000
max=100.000000
levels_color=12632256
levels_style=2
levels_weight=1
level_0=30.0000
level_1=70.0000
period_flags=0
show_data=1
</indicator>
</window>

<window>
height=31
fixed_height=0
<indicator>
name=Custom Indicator
<expert>
name=MACD513
flags=339
window_num=2
<inputs>
InpFastEMA=5
InpSlowEMA=13
InpSignalSMA=1
IsSendMail=false
</inputs>
</expert>
shift_0=0
draw_0=2
color_0=255
style_0=0
weight_0=1
shift_1=0
draw_1=0
color_1=12632256
style_1=0
weight_1=1
shift_2=0
draw_2=2
color_2=65280
style_2=0
weight_2=1
shift_3=0
draw_3=0
color_3=36095
style_3=0
weight_3=1
levels_color=12632256
levels_style=2
levels_weight=1
level_0=0.0000
period_flags=0
show_data=1
<object>
type=1
object_name=Horizontal Line 52353
period_flags=0
create_time=1421200513
color=11186720
style=2
weight=1
background=1
filling=0
selectable=1
hidden=0
zorder=0
value_0=0.001500
</object>
<object>
type=1
object_name=Horizontal Line 52403
period_flags=0
create_time=1421200563
color=11186720
style=2
weight=1
background=1
filling=0
selectable=1
hidden=0
zorder=0
value_0=-0.001500
</object>
<object>
type=1
object_name=Horizontal Line 52412
period_flags=0
create_time=1421200572
color=11186720
style=2
weight=1
background=1
filling=0
selectable=1
hidden=0
zorder=0
value_0=0.003000
</object>
<object>
type=1
object_name=Horizontal Line 52421
period_flags=0
create_time=1421200581
color=11186720
style=2
weight=1
background=1
filling=0
selectable=1
hidden=0
zorder=0
value_0=-0.003000
</object>
<object>
type=1
object_name=Horizontal Line 52433
period_flags=0
create_time=1421200593
color=11186720
style=2
weight=1
background=1
filling=0
selectable=1
hidden=0
zorder=0
value_0=0.004500
</object>
<object>
type=1
object_name=Horizontal Line 52448
period_flags=0
create_time=1421200608
color=11186720
style=2
weight=1
background=1
filling=0
selectable=1
hidden=0
zorder=0
value_0=-0.004500
</object>
</indicator>
</window>
</chart>
