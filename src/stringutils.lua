local find = string.find
local insert = table.insert
local sub = string.sub

function string.explode(div, str)
    if (div=='') then return false end
    local pos,arr = 0,{}
    -- for each divider found
    for st,sp in function() return find(str,div,pos,true) end do
        insert(arr,sub(str,pos,st-1)) -- Attach chars left of current divider
        pos = sp + 1 -- Jump past current divider
    end
    insert(arr,sub(str,pos)) -- Attach chars right of last divider
    return arr
end

-- thank you http://stackoverflow.com/a/23592008/646180
local domains = [[.ac.ad.ae.aero.af.ag.ai.al.am.an.ao.aq.ar.arpa.as.asia.at.au
   .aw.ax.az.ba.bb.bd.be.bf.bg.bh.bi.biz.bj.bm.bn.bo.br.bs.bt.bv.bw.by.bz.ca
   .cat.cc.cd.cf.cg.ch.ci.ck.cl.cm.cn.co.com.coop.cr.cs.cu.cv.cx.cy.cz.dd.de
   .dj.dk.dm.do.dz.ec.edu.ee.eg.eh.er.es.et.eu.fi.firm.fj.fk.fm.fo.fr.fx.ga
   .gb.gd.ge.gf.gh.gi.gl.gm.gn.gov.gp.gq.gr.gs.gt.gu.gw.gy.hk.hm.hn.hr.ht.hu
   .id.ie.il.im.in.info.int.io.iq.ir.is.it.je.jm.jo.jobs.jp.ke.kg.kh.ki.km.kn
   .kp.kr.kw.ky.kz.la.lb.lc.li.lk.lr.ls.lt.lu.lv.ly.ma.mc.md.me.mg.mh.mil.mk
   .ml.mm.mn.mo.mobi.mp.mq.mr.ms.mt.mu.museum.mv.mw.mx.my.mz.na.name.nato.nc
   .ne.net.nf.ng.ni.nl.no.nom.np.nr.nt.nu.nz.om.org.pa.pe.pf.pg.ph.pk.pl.pm
   .pn.post.pr.pro.ps.pt.pw.py.qa.re.ro.ru.rw.sa.sb.sc.sd.se.sg.sh.si.sj.sk
   .sl.sm.sn.so.sr.ss.st.store.su.sv.sy.sz.tc.td.tel.tf.tg.th.tj.tk.tl.tm.tn
   .to.tp.tr.travel.tt.tv.tw.tz.ua.ug.uk.um.us.uy.va.vc.ve.vg.vi.vn.vu.web.wf
   .ws.xxx.ye.yt.yu.za.zm.zr.zw]]
local tlds = {}
for tld in domains:gmatch'%w+' do
    tlds[tld] = true
end
local protocols = {[''] = 0, ['http://'] = 0, ['https://'] = 0, ['ftp://'] = 0 }

function string.has_url(str)
    for pos, url, prot, subd, tld, colon, port, slash, path in str:gmatch
        '()(([%w_.~!*:@&+$/?%%#-]-)(%w[-.%w]*%.)(%w+)(:?)(%d*)(/?)([%w_.~!*:@&+$/?%%#=-]*))'
    do
        if protocols[prot:lower()] == (1 - #slash) * #path
                and (colon == '' or port ~= '' and port + 0 < 65536)
                and (tlds[tld:lower()] or tld:find'^%d+$' and subd:find'^%d+%.%d+%.%d+%.$'
                and math.max(tld, subd:match'^(%d+)%.(%d+)%.(%d+)%.$') < 256)
                and not subd:find'%W%W'
        then
            return true
        end
    end

    return false
end

function string.caps_percent(str)
    local caps = 0
    for i = 1,#str do
        if str:sub(i,i):match("%u") then
            caps = caps + 1
        end
    end

    return caps / #str
end

function string.symbols_percent(str)
    local symbols = 0
    for i = 1,#str do
        if not str:sub(i,i):match("[%s%w]") then
            symbols = symbols + 1
        end
    end

    return symbols / #str
end