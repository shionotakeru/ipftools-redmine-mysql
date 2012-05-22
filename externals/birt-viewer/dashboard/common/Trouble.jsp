<%-----------------------------------------------------------------------------
    <Quantitative project management tool.>
    Copyright (C) 2012 IPA, Japan.

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
-----------------------------------------------------------------------------%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="/birt.tld" prefix="birt" %>
<%@ taglib uri="/ipf.tld" prefix="ipf" %>

<div id="dashboard_title">障害・課題管理パターン(common/Trouble.jsp)</div>


<!-- R_S08 -->
<ipf:authDisp permissions="IPF_GRAPH_S08">
<ipf:graph id="graph8" reportDesign="report/R_S08.rptdesign">
<ipf:graphTitle>障害件数変化(R_S08)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
障害の発生件数、未解決件数の推移の把握、及び計画件数との対比などを行います。また、重要度別の障害発生状況、解決状況を把握します。<br/>
【概要】<br/>
・障害の件数、未解決件数の推移を、重要度（例：軽微、中度、重大など）別の件数も含めて表示します。<br/>
・３種類のグラフを「上段」「中段」「下段」に縦に並べて表示します。<br/>
　　①障害の件数（全件）と未解決数と計画件数を表示するグラフ。<br/>
　　②障害の件数（全件）を重要度別に表示するグラフ。<br/>
　　③未解決件数を重要度別に表示するグラフ。<br/>
・障害件数の表示対象のWBSタスクと、グラフ表示期間（開始日、終了日）をパラメータで指定します。<br/>
・子グラフとして「R_S13：障害解決予測」を表示します。 <br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                                 ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"                   ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${TOP_WBS_TICKET.PLANNED_START_DATE_OR_TODAY}" ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TODAY}"                                      ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S10 -->
<ipf:authDisp permissions="IPF_GRAPH_S10">
<ipf:graph id="graph10" reportDesign="report/R_S10.rptdesign">
<ipf:graphTitle>障害発生密度(R_S10)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
障害発生密度により、品質の悪いWBSのタスク（機能及びモジュール）を把握します。<br/>
【概要】<br/>
・パラメータで指定された表示対象のWBSタスクごとにソース規模に対する障害発生密度を表示します。<br/>
・表示対象とするWBSタスクを、グラフパラメータで指定します。<br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                   ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"     ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S11 -->
<ipf:authDisp permissions="IPF_GRAPH_S11">
<ipf:graph id="graph11" reportDesign="report/R_S11.rptdesign">
<ipf:graphTitle>障害滞留状況(R_S11)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
長期間解決されていない障害を把握します。<br/>
【概要】<br/>
・工程ごとに現在まで解決されていない障害件数を、滞留期間に分けて重要度別に表示します。<br/>
・表示対象の工程をグラフパラメータで指定します。<br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                   ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"     ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S14 -->
<ipf:authDisp permissions="IPF_GRAPH_S14">
<ipf:graph id="graph14" reportDesign="report/R_S14.rptdesign">
<ipf:graphTitle>長期未解決課題抽出(R_S14)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
・長期間解決されていない課題を抽出します。<br/>
【概要】<br/>
・パラメータで指定された期間を超えて未解決状態の課題を重要度別に表示します。<br/>
・表示対象とする滞留期間をグラフパラメータで指定します。<br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"           ></birt:param>
<birt:param name="PERIOD"           value="1"                       ></birt:param>
</ipf:graph>
</ipf:authDisp>

