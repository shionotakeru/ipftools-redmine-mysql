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

<div id="dashboard_title">デフォルトパターン(defaultPettern.jsp)</div>

<!-- R_S01 -->
<ipf:authDisp permissions="IPF_GRAPH_S01">
<ipf:graph id="graph1" reportDesign="report/R_S01.rptdesign">
<ipf:graphTitle>試験計画項目密度(R_S01)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
計画された試験項目の密度により試験項目のカバレッジを確認し、作製した試験項目の過不足の判断を行います。</br>
【概要】</br>
・ソース規模（行数）に対する試験項目の密度を表示します。</br>
・表示対象のWBSタスクと、ソース規模の集計日をグラフパラメータで指定します。</br>
</ipf:graphComment>
<birt:param name="PROJECT_ID"   value="${PROJECT_ID}"                   ></birt:param>
<birt:param name="TICKET_ID"    value="${TOP_WBS_TICKET.TICKET_ID}"     ></birt:param>
<birt:param name="TARGET_DATE"  value="${TODAY}"                        ></birt:param>
</ipf:graph>
</ipf:authDisp>

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
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                    ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET_RS02.TICKET_ID}" ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${ONE_MONTH_AGO}"                 ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${ONE_MONTH_AFTER}"               ></birt:param>
<birt:param name="SCALE"            value="0"                                ></birt:param>
<birt:param name="PRODUCTIVITY"     value=""                                 ></birt:param>
</ipf:graph>
</ipf:authDisp>

<!-- R_S03 -->
<ipf:authDisp permissions="IPF_GRAPH_S03">
<ipf:graph id="graph3" reportDesign="report/R_S03.rptdesign">
<ipf:graphTitle>WBS進捗変化(R_S03)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
最近の進捗率変化分を確認し、進捗上問題の有るタスクの確認を行います。<br/>
【概要】<br/>
・「R_S02：WBS進捗推移」の子グラフですが、ナビゲーションエリアから単独表示も可能です。<br/>
・パラメータで指定したWBSタスクの生産性変化（進捗率の変化）を表示します。<br/>
・R_S02の子グラフとして表示された場合：<br/>
　R_S02を表示する際に入力されたパラメータ（表示期間とスケール）と、R_S02で表示中または一覧から選択したWBSタスクを引き継ぎます。<br/>
・ナビゲーションエリアから表示された場合：<br/> 
　グラフ表示期間（開始日、終了日）と、スケール（週単位／月単位）をグラフパラメータで指定します。 <br/>
　グラフ表示期間中にあるWBSタスクの最上位を初期表示します。 <br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                     ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET_RS02.TICKET_ID}"  ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${ONE_MONTH_AGO}"                  ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TODAY}"                          ></birt:param>
<birt:param name="SCALE"            value="0"                                 ></birt:param>
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


<!-- R_S05 -->
<ipf:authDisp permissions="IPF_GRAPH_S05">
<ipf:graph id="graph5" reportDesign="report/R_S05.rptdesign">
<ipf:graphTitle>ソフトウェア規模推移(R_S05)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
ソース規模実績値の推移、及び計画値との対比を行い、製造工程での進捗確認、及び試験工程での品質低下の予兆がないか確認します。<br/>
【概要】<br/>
・パラメータ指定の期間内で、現在までのソース規模の実績推移、実績変化分、予実割合を週ごとに表示します。<br/>
・表示対象のWBSタスクと、グラフ表示期間（開始日、終了日）をグラフパラメータで指定します。<br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                                 ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"                   ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${TOP_WBS_TICKET.PLANNED_START_DATE_OR_TODAY}" ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TODAY}"                                      ></birt:param>
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


<!-- R_S07 -->
<ipf:authDisp permissions="IPF_GRAPH_S07">
<ipf:graph id="graph7" reportDesign="report/R_S07.rptdesign">
<ipf:graphTitle>工数の予実(R_S07)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
現状の消化工数が計画とどれくらい乖離しているか、完成時の予想工数はどれくらいになるかを把握します。<br/>
【概要】<br/>
・パラメータで指定した期間内で、工数の予実比較と予想工数を表示します。<br/>
・表示対象のWBSタスクと、グラフ表示期間（開始日、終了日）、スケール（週単位／月単位）をグラフパラメータで指定します。<br/>
・想定工数を求める生産性として、現時点の生産性の割合が、今回のみの特別なものか、将来も続くものと判断するか、グラフパラメータで指定します。<br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                       ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"         ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${TOP_WBS_TICKET.PLANNED_START_DATE}"></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TOP_WBS_TICKET.PLANNED_END_DATE}"  ></birt:param>
<birt:param name="SCALE"            value="0"                                   ></birt:param>
<birt:param name="PRODUCTIVITY"     value="0"                                   ></birt:param>
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


<!-- R_S09 -->
<ipf:authDisp permissions="IPF_GRAPH_S09">
<ipf:graph id="graph9" reportDesign="report/R_S09.rptdesign">
<ipf:graphTitle>障害原因分析(R_S09)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
現在の障害件数を原因別に分類し障害原因傾向を把握します。<br/>
【概要】<br/>
・障害原因ごとの解決数と未解決数を表示します。<br/>
・表示対象のWBSタスクをグラフパラメータで指定します。<br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                   ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"     ></birt:param>
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


<!-- R_S12 -->
<ipf:authDisp permissions="IPF_GRAPH_S12">
<ipf:graph id="graph12" reportDesign="report/R_S12.rptdesign">
<ipf:graphTitle>負荷状況(R_S12)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
・開発者の負荷を把握します。<br/>
・集計期間（開始日、終了日）、稼働時間閾値、表示種別、開発者名をグラフパラメータで指定します。<br/>
【概要】<br/>
・パラメータで指定した期間内で、開発者の負荷比較を行います。<br/>
・パラメータで指定した期間内で、開発者の負荷比較を行います。<br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"           ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${ONE_MONTH_AGO}"        ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TODAY}"                ></birt:param>
<birt:param name="SELECT_OUTPUT"    value="0"                       ></birt:param>
<birt:param name="BORDER_TIME"      value="160"                     ></birt:param>
<birt:param name="WORKER_ID"        value="0"                       ></birt:param>
</ipf:graph>
</ipf:authDisp>


<!-- R_S13 -->
<ipf:authDisp permissions="IPF_GRAPH_S13">
<ipf:graph id="graph13" reportDesign="report/R_S13.rptdesign">
<ipf:graphTitle>障害解決予測(R_S13)</ipf:graphTitle>
<ipf:graphComment>
【目的】<br/>
・WBSのタスクごとに、障害の未解決数と解決生産性から解決完了日を推定します。<br/>
【概要】<br/>
・「R_S08：障害件数変化」の子グラフですが、ナビゲーションエリアから単独での表示も可能です。<br/>
・パラメータで指定された期間の障害解決生産性を求め、現在から解決完了日までの障害解決進捗率の推移予測を表示します。<br/>
・R_S08の子グラフとして表示された場合<br/>
　　R_S08を表示する際に入力されたパラメータ（表示期間）と、R_S08で表示中のWBSタスクを引き継ぎます。<br/>
　　R_S08で表示されていた期間の解決生産性の変化分から進捗率の推移予測を行います。<br/>
・ナビゲーションエリアから表示された場合<br/>
　　表示対象のWBSタスクと、障害解決生産性算出期間（開始日、終了日）をグラフパラメータで指定します。 <br/>
</ipf:graphComment>
<birt:param name="PROJECT_ID"       value="${PROJECT_ID}"                                 ></birt:param>
<birt:param name="TICKET_ID"        value="${TOP_WBS_TICKET.TICKET_ID}"                   ></birt:param>
<birt:param name="TARGET_DATE_FROM" value="${TOP_WBS_TICKET.PLANNED_START_DATE_OR_TODAY}" ></birt:param>
<birt:param name="TARGET_DATE_TO"   value="${TODAY}"                                      ></birt:param>
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


