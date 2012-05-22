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
<%@ taglib uri="/ipf.tld"  prefix="ipf" %>

<birt:viewer id="birtViewer${result.graphId}" reportDesign="${result.reportFilePath}"
pattern="preview"
style="width:100%;height:100%;background-color:#FFFFFF"
format="html">
<%-- 共通パラメータ --%>
<ipf:param name="NAVI_CREATE_FLAG"     value="true"                        ></ipf:param>
<ipf:param name="PROJECT_ID"           value="${result.PROJECT_ID}"        ></ipf:param>
<ipf:param name="USER_ID"              value="${USER_ID}"                  ></ipf:param>
<ipf:param name="TICKET_ID"            value="${param.TICKET_ID}"          ></ipf:param>
<ipf:param name="TARGET_DATE"          value="${param.TARGET_DATE}"        ></ipf:param>
<ipf:param name="TARGET_DATE_FROM"     value="${param.TARGET_DATE_FROM}"   ></ipf:param>
<ipf:param name="TARGET_DATE_TO"       value="${param.TARGET_DATE_TO}"     ></ipf:param>
<ipf:param name="SCALE"                value="${param.SCALE}"              ></ipf:param>
<ipf:param name="PRODUCTIVITY"         value="${param.PRODUCTIVITY}"       ></ipf:param>
<ipf:param name="COST"                 value="${param.COST}"               ></ipf:param>
<ipf:param name="SELECT_OUTPUT"        value="${param.SELECT_OUTPUT}"      ></ipf:param>
<ipf:param name="XAXIS_COUNT"          value="${param.XAXIS_COUNT}"        ></ipf:param>
<ipf:param name="BORDER_TIME"          value="${param.BORDER_TIME}"        ></ipf:param>
<ipf:param name="WORKER_ID"            value="${param.WORKER_ID}"          ></ipf:param>
<ipf:param name="PERIOD"               value="${param.PERIOD}"             ></ipf:param>
<ipf:param name="SEVERITY"             value="${param.SEVERITY}"           ></ipf:param>
<ipf:param name="NAVI_TIME"            value="${result.t}"                 ></ipf:param>
</birt:viewer>
