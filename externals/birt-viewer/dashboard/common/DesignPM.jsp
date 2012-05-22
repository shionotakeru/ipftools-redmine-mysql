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

<div id="dashboard_title">設計工程（PM向け）(common/DesignPM.jsp)</div>

<!-- R_S02 -->
<ipf:authDisp permissions="IPF_GRAPH_S02">
<ipf:graph id="graph2" reportDesign="report/R_S02.rptdesign">
<ipf:graphTitle>WBS進捗推移(R_S02)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
過去の進捗率から、今後の開発の進み具合を予測し、タスク完了予定日を把握します。<br/>
【概要】<br/>
・パラメータで指定したWBSタスクの進捗推移を表示します。<br/>
・グラフ表示期間（開始日、終了日）と、スケール（週単位／月単位）、及び予測線を表示する為の進捗率変化分をグラフパラメータで指定します。<br/>
・グラフ表示期間の終了日に、未来の日付を指定した場合、進捗率の予測線を表示します。<br/>
・表示対象のWBSタスクの計画値（開始日、終了予定日）と予測日（終了予定日）を一覧で表示します。<br/>
・子グラフとして、「R_S03：WBS進捗変化」グラフを表示します。 <br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                   ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET_RS02.TICKET_ID}"></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${ONE_MONTH_AGO}"                ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${ONE_MONTH_AFTER}"              ></birt:param>
<birt:param name="SCALE"            value="0"                               ></birt:param>
<birt:param name="PRODUCTIVITY"     value=""                                ></birt:param>
</ipf:graph>
</ipf:authDisp>


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


<!-- R_S15 -->
<ipf:authDisp permissions="IPF_GRAPH_S15">
<ipf:graph id="graph15" reportDesign="report/R_S15.rptdesign">
<ipf:graphTitle>遅延重要タスク抽出(R_S15)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
・予測遅延日数の大きなWBSタスクを抽出することにより、対策が必要なWBSタスクの確認を行います。<br/>
【概要】<br/>
・WBSタスクの進捗率を基に遅延予測を行い、その予測遅延日数を表示します。<br/>
・表示対象とするWBSタスクの重要度をパラメータで選択します。<br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"           ></birt:param>
<birt:param name="SEVERITY"         value="1"                       ></birt:param>
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
