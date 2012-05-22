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

<div id="dashboard_title">試験工程（PM向け）(common/TestPM.jsp)</div>


<!-- R_S04 -->
<ipf:authDisp permissions="IPF_GRAPH_S04">
<ipf:graph id="graph4" reportDesign="report/R_S04.rptdesign">
<ipf:graphTitle>EVM評価（進捗、工数）(R_S04)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
EVMにより最近の生産価値とコスト（工数）の予実を把握します。<br/>
【概要】<br/>
・生産価値（EV）とコスト（AC）と計画値（PV）のEVMグラフを描画します。<br/>
・表示対象のWBSタスクと、グラフ表示期間（開始日、終了日）、スケール（週単位／月単位）をグラフパラメータで指定します。<br/>
・生産価値（EV）の計算に使用する進捗率は、ソース規模から求めるか、工数から求めるかを選択可能とし、グラフパラメータで指定します。<br/>
・生産性として、現時点の生産性の割合が、今回のみの特別なものか、将来も続くものと判断するか、グラフパラメータで指定します。<br/>
・現時点の生産性の割合が将来も継続するとした場合、コスト効率（CPI)、スケジュール効率（SPI)を考慮し、予測線を求めます。<br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                           ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"             ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${TOP_WBS_TICKET.PLANNED_START_DATE}"    ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TOP_WBS_TICKET.PLANNED_END_DATE}"      ></birt:param>
<birt:param name="SCALE"            value="0"                                       ></birt:param>
<birt:param name="PRODUCTIVITY"     value="1"                                       ></birt:param>
<birt:param name="COST"             value="0"                                       ></birt:param>
</ipf:graph>
</ipf:authDisp>



<!-- R_S06 -->
<ipf:authDisp permissions="IPF_GRAPH_S06">
<ipf:graph id="graph6" reportDesign="report/R_S06.rptdesign">
<ipf:graphTitle>試験進捗率(R_S06)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
タスクごとの試験項目実施状況を「達成率」または「実件数」で確認し、試験の計画及び実施の進捗状況を把握します。 過去ｎ週間の実施分を積み上げ棒グラフで表示し、直近の進捗も把握します。<br/>
【概要】<br/>
・パラメータで指定した期間内で、週ごとの試験進捗の達成率、または実件数を積み上げ棒グラフで表示します。<br/>
・表示対象のWBSタスクと、グラフ表示期間（開始日、終了日）、表示種別として達成率／実件数のどちらのグラフを表示するか、及び系列値出力制限数をグラフパラメータで指定します。<br/>
・グラフ表示期間の終了日に未来の日付を指定した場合、実件数グラフでは期間内にある計画値を表示します。<br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                                 ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"                   ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${TOP_WBS_TICKET.PLANNED_START_DATE_OR_TODAY}" ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TODAY}"                                      ></birt:param>
<birt:param name="SELECT_OUTPUT"    value="0"                                             ></birt:param>
<birt:param name="XAXIS_COUNT"      value=""                                              ></birt:param>
</ipf:graph>
</ipf:authDisp>

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

