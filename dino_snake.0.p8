pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--globals and init
scenter=64--screen center
frc=0.85--friction
fflg=2--food flag
mflg=1--map flag
actfrg={}--active forage
--dev
log=""

function _init()
	inichar()
	inilfcy()
end
-->8
--update and draw

function _update()
	--mvset.update()
end

function _draw()
	cls()
	if (log!="") ?log
	upchar()
	--upfrg()
	uplfcy()
	upnme()
	map()
	print(char.p)
	drwnme()
	drwchar()
	--drwfrg()
	--ray(char)
	--camera(char.x-scenter+(char.w/2),char.y-scenter+(char.h/2))
end
-->8
--character

char={
	mv,--state
	a=1.0,--angel
	lfs=0,--life stage
	x=0,
	y=0,
	h=4,
	w=4,
	vx=0,
	vy=0,
	acc=0.75,
	vmax=3,--velocity max
	p=0,
	grwnum=0,
	--animation
	ani="0,1,2,3",
	flp=false--flip
}
function vlimit(v,m)--limit velocity
	return mid(-m,v,m)
end
--initialize character
function inichar()
	char.x=scenter-(char.w/2)
	char.y=scenter-(char.h/2)
	char.mv=mvset.idl
	char.mv.enter()
	lfcy.stg=lfcy.hch
	lfcy.stg.enter()
end
--update character
function upchar()
	upmvset()
	mvsld(char)--move and slide
end
--draw character
function drwchar()
	--spr(
		--split(char.ani)[1],
		--char.x,
		--char.y,
		--1,
		--1,
		--char.flp
	--)
	rectfill(
		char.x,
		char.y,
		char.x+char.w,
		char.y+char.h,
		4
	)
end
-->8
--state machine
	--moveset state machine
function mvcon(--move constructor
	lbl,--label
	snum,--sprite number
	vaxs,--velocity access
	vdir,--velocity direction
	flp,--flip, optional
	a--angel
	)
	if (a==nil) a=1
	return{
		lbl=lbl,
		update=function()
			print(lbl)
			char[vaxs]+=(char.acc*vdir)
			char[vaxs]=vlimit(char[vaxs],char.vmax)
			char.a = a
		end,
		enter=function()
			--char.hbv=mvset[lbl].ofv
			char.ani=snum
			char.flp=flp
		end,
		exit=function()
			--char.hbv=mvset[lbl].ofv
			char.flp=false
		end
	}
end
function mvprog(i)--move progress
	if i!=char.mv.lbl then
		local nmv=mvset[i]--new move
		char.mv.exit()
		nmv.enter()
		char.mv=nmv
	end
	char.mv.update(iget())
end
function iget()--input collector
	local i="idl"--input
	if (btn(0)) i="lrun"
	if (btn(1)) i="rrun"
	if (btn(2)) i="urun"
	if (btn(3)) i="drun"
	if (btn(4)) i="eat"
	return i
end
function upmvset()--update moveset
	mvprog(iget())
end
mvset={--move set states
	idl={
		update=function(i)
			if i!="idl" then
				char.mv=mvset.mv[i]
			else
				print("idl")
			end
		end,
		enter=function()
			char.ani="16"
		end,
		exit= function()
		end
	},
	eat={
		update=function(i)
		end,
		enter= function()
		end,
		exit= function()
		end
	},
	lrun=mvcon(
		"lrun",
		"0",
		"vx",
		-1,
		true
	),
	rrun=mvcon(
		"rrun",
		"4",
		"vx",
		1
	),
	urun=mvcon(
		"urun",
		"8",
		"vy",
		-1
	),
	drun=mvcon(
		"drun",
		"12",
		"vy",
		1
	)
}
--life cycle
--state machine
--progress lifecycle
function proglfcy()
	if char.p>=char.grwnum then
		lfcy.stg.exit()
		lfcy.stg.enter()
	end
	--lfcy.stg.update()
end

--life stage constructor
function lstgcon(
	lfl,
	nxt,
	ani,
	h,
	w,
	gnum
	)
	--appropriate food for specific life stage
	return {
		lbl=lfl,
		enter=function()
			char.grwnum=gnum
			char.ani=ani
			char.h=h
			char.w=w
			char.w=w
			actfrg=split("bug,bug,rdt,lzd")
			--msg= #actfrg
				--set appropraite food type
					--a string of keys to a
					--table of food type tables
					--setforagetype("bugs,lizard,mice")
					--fds={type={spritenumber=0}}
		end,
		exit=function()
			lfcy.stg=lfcy[nxt]
		end,
	}
end
--life cycle
lfcy={
	stg=nil,--current life stage
	egg=lstgcon(
		"egg",
		"hch",
		"0",
		4,
		4,
		0
	),
	--hatchling
	hch=lstgcon(
		"hch",
		"juv",
		"0",
		4,
		4,
		10
	),
	--juvenile
	juv=lstgcon(
		"juv",
		"ado",
		"0",
		7,
		7,
		20
	),
	--adolescence
	ado=lstgcon(
		"ado",
		"adt",
		"0",
		16,
		16,
		30
	),
	--adult
	adt=lstgcon(
		"adt",
		"egg",
		"0",
		32,
		32,
		1000
	),
}
--update lifecyle
function uplfcy()
	proglfcy()
	print(lfcy.stg.lbl)
end
--initialize lifecyle
function inilfcy()
	--lfcy.adt.enter=function()
		--open the win state menu
	--end
	--lfcy.adt.exit=function()end
	lfcy.stg.enter()
end

-->8
--functions
--raycast
function ray(obj,scrx)
	if (scrx==nil) scrx=1
	local raya=
		obj.a+0.125-0.25*scrx/128
	local rayvx,rayvy=
		cos(raya),sin(raya)
	line(
		obj.x,obj.y,
		obj.x+rayvx*64,
		obj.y+rayvy*64,
		8+scrx%8
	)
end
	--get current hitbox vector
function hbvget(obj,osv)
	--object --offset vector
	return {
		x1=(obj.x+osv.x1)+obj.vx,
		y1=(obj.y+osv.y1)+obj.vy,
		x2=(obj.x+osv.x2)+obj.vx,
		y2=(obj.y+osv.y2)+obj.vy,
	}
end
function pys(obj,vk,hbv)--physics
	--vk veolcity key
	obj[vk]*=frc
	--map collisions
	mpcol(obj,hbv)
end
--move and slide
function mvsld(obj)
	local hbv={}
	if obj.vx<0 then
		hbv={
			x1=-1,
			y1=0,
			x2=-1,
			y2=obj.h
		}
		hbv=hbvget(obj,hbv)
		pys(obj,"vx",hbv)
	end
	if obj.vx>0 then
		hbv={
			x1=obj.w+1,
			y1=0,
			x2=obj.w+1,
			y2=obj.h
		}
		hbv=hbvget(obj,hbv)
		pys(obj,"vx",hbv)
	end
	if obj.vy<0 then
		hbv={
			x1=0,
			y1=-1,
			x2=obj.w,
			y2=-1
		}
		hbv=hbvget(obj,hbv)
		pys(obj,"vy",hbv)
	end
	if obj.vy>0 then
		hbv={
			x1=0,
			y1=obj.h+1,
			x2=obj.w,
			y2=obj.h+1
		}
		hbv=hbvget(obj,hbv)
		pys(obj,"vy",hbv)
	end
	obj.x+=obj.vx
	obj.y+=obj.vy
end
--is collison
function iscol(hbv,flg)
	local x1=flr(hbv.x1/8)
	local x2=flr(hbv.x2/8)
	local y1=flr(hbv.y1/8)
	local y2=flr(hbv.y2/8)
	--dev
	rectfill(
		hbv.x1,
		hbv.y1,
		hbv.x2,
		hbv.y2,
		7
	)
	--x1 y1 top left corner
	if fget(mget(x1,y1),flg) then
		return true 
	end
	--x1 y2 bottom left corner
	if fget(mget(x1,y2),flg) then
		return true 
	end
	--x2 y1 top right corner
	if fget(mget(x2,y1),flg) then
		return true 
	end
	--x2 y2 bottom right corner
	if fget(mget(x2,y2),flg) then
		return true
	end
		--return true
	--end
	local xtl=(hbv.x2-hbv.x1)/8
	local ytl=(hbv.y2-hbv.y1)/8
	local cx=x1
	local cy=y1
	if xtl>1 then
		for lp=0,xtl do
			if fget(mget(cx,y1),flg)
			or fget(mget(cx,y2),flg)then
				return true
			end
			--lp+=1
			cx+=1
		end
	end
	if ytl>1 then
		for lp=0,ytl do
			if fget(mget(x1,cy),flg)
			or fget(mget(x2,cy),flg)then
				return true
			end
			cy+=1
		end
	end
	log="cy: "..cy.." y2: "..y2.." ytl: "..ytl.." height: "..hbv.y2-hbv.y1
	return false
end
--map collision
function mpcol(obj,hbv)
	local vx=abs(obj.vx)
	local vy=abs(obj.vy)
	local nhbv=hbv
	if iscol(nhbv,mflg) then
		if vx>0 then
			obj.vx=0
		elseif vy>0 then
			obj.vy=0
		end
	end
end

function ismpcol(x1,y1,h,w)
	local x2 = x1+w/8
	local y2 = y1+h/8
	x1/=8
	y1/=8
	return fget(mget(x1,y1),mflg)
	or fget(mget(x1,y2),mflg)
	or fget(mget(x2,y1),mflg)
	or fget(mget(x2,y2),mflg)
end

function dist(fx,fy,tx,ty)
	--f = from
	--t = to
	local dx,dy=fx-tx,fy-ty
	--d = difference
	--pythagoras theorem
	return sqrt(dx^2+dy^2)
end
-->8
--vector
function vector(x,y) return {x=x or 0,y=y or 0} end

function v_polar(a,l) return vector(l*cos(a),l*sin(a)) end
function v_rnd()      return v_polar(rnd(),1)          end
function v_copy(v)    return vector(v.x,v.y) end
function v_unpack(v)  return v.x, v.y end
function v_tostr(v)   return "["..v.x..", "..v.y.."]" end

function v_add(a,b)   return vector(a.x+b.x, a.y+b.y) end
function v_sub(a,b)   return v_add(a, v_neg(b)) end
function v_scale(v,n) return vector(v.x*n, v.y*n) end
v_mul=v_scale
function v_div(v,n)   return v_scale(v, 1/n) end
function v_neg(v)     return v_scale(v, -1) end

function v_dot(a,b)    return a.x*b.x+a.y*b.y end
function v_magsq(v)    return v_dot(v,v) end
function v_mag(v)      return sqrt(v_magsq(v)) end
function v_distsq(a,b) return v_magsq(v_sub(b,a)) end
function v_dist(a,b)   return sqrt(v_distsq(a,b)) end
function v_norm(v)     return v_div(v,v_mag(v)) end
function v_perp(v)     return vector(v.y, -v.x) end
function v_dir(a,b)    return v_norm(v_sub(b,a)) end

function v_proj(a,b)
    return v_scale(a, v_dot(a,b)/v_magsq(a))
end

function v_angle(v)   return atan2(v.x,v.y)        end
function v_rot(v,a)   return v_polar(a, v_mag(v))  end
function v_rotby(v,a) return v_rot(v,v_angle(v)+a) end

function v_lerp(a,b,t) return v_add(a,v_mul(v_sub(b,a),t)) end
function v_flr(v) return vector(flr(v.x),flr(v.y)) end

v_right = vector( 1, 0)
v_left  = vector(-1, 0)
v_down  = vector( 0, 1)
v_up    = vector( 0,-1)

v_one    = vector(1,1)
v_center = vector(64,64)
-->8
--food

--forage, food available to player
function frgcon(h,w,pnt,ani)
	return {
		h=h,
		w=w,
		pnt=pnt,
		ani=ani
	}
end

--ingame forage
frg={}

frgtyp={
	bug=frgcon(
		8,
		8,
		1,
		32
	),
	lzd=frgcon(
		8,
		8,
		1,
		32
	),
	rdt=frgcon(
		8,
		8,
		1,
		32
	),
	scv=frgcon(
		8,
		8,
		1,
		32
	),
	egg=frgcon(
		8,
		8,
		1,
		32
	),
}
--forage minium
fmin=3

--update forage
function upfrg()
	for f in all(frg) do
		if isfrgcol(f) then
			onfrgcol(f)
		end
	end
	frgspwn()
end
--is forage collision
function isfrgcol(f)
	--dev
	rectfill(
		f.x,
		f.y,
		f.x+7,
		f.y+7,
		8
	)
	if f.y>char.y+char.h
	or char.y>f.y+f.h
	or f.x>char.x+char.w
	or char.x>f.x+f.w then
		return false
	end
	return true
end
--on forage collision
function onfrgcol(f)
	char.p+=1
	--grow the character
	del(frg,f)
end
--forage spawn
function frgspwn()
	local l=fmin
	if #frg<fmin then
		while l>0 do
			local tx=flr(rnd(16))
			local ty=flr(rnd(16))
			local fx=tx*8
			local fy=ty*8
			local i=mid(1,flr(rnd(#actfrg+1)),#actfrg)
			local fk=actfrg[i]
			local fd=frgtyp[fk]
			if not ismpcol(fx,fy,8,8) then
				add(
					frg,
					{
						x=fx,
						y=fy,
						h=fd.h,
						w=fd.w,
						ani=fd.ani,
						pt=fd.pt,
						lbl=fk
					}
				)
				l-=1
			end
		end
	end
end

function drwfrg()
	for f in all(frg) do
		print(f.lbl,f.x,f.y,10)
		spr(
			f.ani,
			f.x,
			f.y,
			1,
			1
		)
	end
end
-->8
--enemies
--n m e...
	dirmap={
		{x=-1, y=0},--left
		{x=1, y=0},--right
		{x=0, y=-1},--up
		{x=0, y=1}--down
	}--direction map
nme={}
nmemin=1

function nmecon(
	x,
	y,
	h,
	w,
	xv,
	yv,
	acc,
	vmax,
	lfst,
	ani
)
	return {
		x=x,
		y=y,
		h=h,
		w=w,
		vx=vx,
		vy=vy,
		acc=acc,
		vmax=vmax,
		lfst=lfst,
		ani=ani,
		--ai
		los=30,
		bi=1,
		interest_map={},
		danger_map={},--danger
		context_map={} --context map
	}
end

function ininme()
end

function nmespwn()
	local c = nmemin
	if #nme < nmemin then
		while c>0 do
			local e = nmecon(
				scenter-4,
				112,
				8,
				8,
				0,
				0,
				0.75,
				3,
				"ado",
				0
			)
			add(nme, e)
			c-=1
		end
	end
end

function nmeray(e)
		local xr=e.y+(e.h*0.5)
		local yr=e.x+(e.w*0.5)
		local left=e.x-1
		local right=e.x+e.w+1
		local up=e.y-1
		local down=e.y+e.h+1
	for l=1,e.los do
		if ismpcol(left, xr, e.h, e.w) then
			e.danger_map[1]=5
		else
		pset(left,xr,6)
			left-=1
		end
		if ismpcol(right, xr, e.h, e.w) then
			e.danger_map[2]=5
		else
			pset(right,xr,6)
			right+=1
		end
		if ismpcol(yr, up, e.h, e.w) then
			e.danger_map[3]=5
		else
			pset(yr,up,6)
			up-=1
		end
		if ismpcol(yr, down, e.h, e.w) then
			e.danger_map[4]=5
		else
			pset(yr,down,6)
			down+=1
		end
	end
end

function upnme()
	for l=1,128 do

	end
	for e in all(nme) do
		nmeray(e)
		get_interest_map(e)
		get_danger_map(e)
		get_context_map(e)
		nmewalk(e)
	end
	nmespwn()
end

function drwnme()
	for e in all(nme) do
		rectfill(
			e.x,
			e.y,
			e.x+e.w,
			e.y+e.h,
			4
		)
		log="e.bi: "..e.bi
	end
end

nmemv={
	idl={},
	prsu={}
}

function get_interest_map(e)
		e.interest_map={}
	local char_v = v_sub(char, e)
	char_v = v_norm(char_v)
	local bv=0
	local bi=1
	for i=1, #dirmap do
		local dot = v_dot(char_v, dirmap[i])
		add(e.interest_map, dot)
		if (dot>bv) bi,bv=i,dot
	end
end
function get_danger_map(e)
	e.danger_map={}
	for m in all(dirmap) do
		add(e.danger_map,0)
	end
end
function get_context_map(e)
	e.context_map={}
	local bv=e.interest_map[1] - e.danger_map[1]
	local bi=1
	for i=1, #dirmap do
		local v=e.interest_map[i] - e.danger_map[i]
		add(e.context_map, v)
		if (v>bv) bv,bi=v,i
	end
	e.bi = bi
end

function nmewalk(e)
	local vel={x=0,y=0}
	vel=v_add(vel,dirmap[e.bi])
	--vel.x=vlimit(e.x,e.vmax)
	--vel.y=vlimit(e.y,e.vmax)
	--vel.x*=frc
	--vel.y*=frc
	e.x+=vel.x
	e.y+=vel.y
end
-->8
---pathfinding

function mkmap(d)
	--d default value
	local nmp={}--new map
	if d==nil then
		d=0
	end
	for x=0,15 do
		nmp[x]={}
		for y=0,15 do
			nmp[x][y]=d
		end
	end
	return nmp
end

--make flow map
function mkflwmap()
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbbb00000000000000000000000000bbbbbb00000000000000000000000000bbbbbb00000000000000000000000000bbbbbb0000000000000000000000000
0b1bbbb00000000000000000000000000b11bbb00000000000000000000000000b1b1bb00000000000000000000000000b11bbb0000000000000000000000000
0b1bbbb00000000000000000000000000b1b1bb00000000000000000000000000b1b1bb00000000000000000000000000b1b1bb0000000000000000000000000
0b1bbbb00000000000000000000000000b11bbb00000000000000000000000000b1b1bb00000000000000000000000000b1b1bb0000000000000000000000000
0b1bbbb00000000000000000000000000b1b1bb00000000000000000000000000b1b1bb00000000000000000000000000b1b1bb0000000000000000000000000
0b111bb00000000000000000000000000b1b1bb00000000000000000000000000b111bb00000000000000000000000000b11bbb0000000000000000000000000
0bbbbbb00000000000000000000000000bbbbbb00000000000000000000000000bbbbbb00000000000000000000000000bbbbbb0000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b111bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bb1bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bb1bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bb1bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0b111bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0bbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004aa400cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004a4400cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004aa400cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
004a4400cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000021212121210000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
