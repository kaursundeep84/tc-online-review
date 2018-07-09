<%--
  - Author: TCSASSEMBLER
  - Version: 2.2
  - Copyright (C) 2005 - 2014 TopCoder Inc., All Rights Reserved.
  - changes in the Topcoder - Online Review Update - Post to Event BUS v1.0
  - - add the handleEventOfAppealResponse js function to fire the appeal response event
  - changes in the version 2.2 (Topcoder - Online Review Update - Post to Event BUS Part 2 v1.0)
  - - add the handleEventOfAppeal js function to fire the appeal submit event
  - Description: This page renders the Review scorecard.
--%>
<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page language="java" isELIgnored="false" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="s" uri="/struts-tags" %>
<%@ taglib prefix="or" uri="/or-tags" %>
<%@ taglib prefix="orfn" uri="/tags/or-functions" %>
<%@ taglib prefix="tc-webtag" uri="/tags/tc-webtags" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<head>
    <jsp:include page="/includes/project/project_title.jsp">
        <jsp:param name="thirdLevelPageKey" value="viewReview.title.${reviewType}" />
    </jsp:include>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

    <!-- TopCoder CSS -->
    <link type="text/css" rel="stylesheet" href="/css/style.css" />
    <link type="text/css" rel="stylesheet" href="/css/coders.css" />
    <link type="text/css" rel="stylesheet" href="/css/stats.css" />
    <link type="text/css" rel="stylesheet" href="/css/tcStyles.css" />

    <!-- CSS and JS by Petar -->
    <link type="text/css" rel="stylesheet" href="/css/or/new_styles.css" />
    <script language="JavaScript" type="text/javascript" src="/js/or/rollovers2.js"><!-- @ --></script>
    <script language="JavaScript" type="text/javascript" src="/js/or/dojo.js"><!-- @ --></script>
    <script language="JavaScript" type="text/javascript">
        var ajaxSupportUrl = "<or:url value='/ajaxSupport' />";
        var challengeId = '${project.id}';
        function handleEventOfAppealResponse(reviewId) {
            // create the Ajax request
            var myRequest = createXMLHttpRequest();
        
            // set the callback function
            // TODO: Check for errors not handled by Ajax Support
            myRequest.onreadystatechange = function() {
                if (myRequest.readyState == 4 && myRequest.status == 200) {
                    // the response is ready.
                }
            };

            // send the request
            myRequest.open('GET', '<%=request.getContextPath() %>/actions/eventBusHandleAppealResponseAction?reviewId=' + reviewId, true);
            myRequest.send(null);
        }
        
        /**
         * Fire the appeal submit event to the event bus
         *
         * @param challengeId the challenge id of the appeal 
         */
        function handleEventOfAppeal(challengeId) {
            // create the Ajax request
            var myRequest = createXMLHttpRequest();
        
            // set the callback function
            // TODO: Check for errors not handled by Ajax Support
            myRequest.onreadystatechange = function() {
                if (myRequest.readyState == 4 && myRequest.status == 200) {
                    // the response is ready.
                }
            };

            // send the request
            myRequest.open('GET', '<%=request.getContextPath() %>/actions/eventBusHandleAppealAction?challengeId=' + challengeId, true);
            myRequest.send(null);
        }
    </script>
    <script language="JavaScript" type="text/javascript" src="/js/or/ajax1.js"><!-- @ --></script>
    <script language="JavaScript" type="text/javascript" src="/js/or/util.js"><!-- @ --></script>
    <script language="JavaScript" type="text/javascript">

        /**
         * TODO: Document it
         */
        function placeAppeal(itemIdx, itemId, reviewId) {
            // Find appeal text input node
            appealTextNode = document.getElementsByName("appeal_text[" + itemIdx + "]")[0];
            // Get html-encoded Appeal text
            var appealText = appealTextNode.value.replace(/\r\n/g, "\n");
            appealText = trimString(appealText);
            var appealTextLength = appealText.length;

            // assemble the request XML
            var content =
                '<?xml version="1.0" ?>' +
                '<request type="PlaceAppeal">' +
                "<parameters>" +
                '<parameter name="ReviewId">' +
                reviewId +
                "</parameter>" +
                '<parameter name="ItemId">' +
                itemId +
                "</parameter>" +
                '<parameter name="Text"><![CDATA[' +
                appealText +
                "]]></parameter>" +
                '<parameter name="TextLength">' +
                appealTextLength +
                "</parameter>" +
                "</parameters>" +
                "</request>";

            // Send the AJAX request
            sendRequest(content,
                function (result, respXML) {
                    // operation succeeded
                    // TODO: Some changes to here
                    toggleDisplay("appealText_" + itemIdx);
                    handleEventOfAppeal(challengeId);
                },
                function (result, respXML) {
                    // operation failed, alert the error message to the user
                    if (result.toLowerCase() == "possible text cutoff error") {
                        alert("<or:text key='viewReview.appealCutoffWarning' />");
                    } else alert("An error occured while placing the appeal: " + result);
                }
            );
        }

        /**
         * TODO: Document it
         */
        function placeAppealResponse(itemIdx, itemId, reviewId) {
            // Find appeal response text input node
            responseTextNode = document.getElementsByName("appeal_response_text[" + itemIdx + "]")[0];
            // Get appeal response text
            var responseText = responseTextNode.value;

            // Find appeal response modified answer node
            answerNode = document.getElementsByName("answer[" + itemIdx + "]")[0];
            // Retrieve modified answer value
            modifiedAnswer = answerNode.value;

            // Find the appeal success status node
            appealSuccessNode = document.getElementsByName("appeal_response_success[" + itemIdx + "]")[0];

            // assemble the request XML
            var content =
                '<?xml version="1.0" ?>' +
                '<request type="ResolveAppeal">' +
                '<parameters>' +
                '<parameter name="ReviewId">' +
                reviewId +
                '</parameter>' +
                '<parameter name="ItemId">' +
                itemId +
                '</parameter>' +
                '<parameter name="Text"><![CDATA[' +
                responseText +
                ']]></parameter>' +
                '<parameter name="Answer">' +
                modifiedAnswer +
                '</parameter>' +
                '<parameter name="Status">' +
                (appealSuccessNode.checked ? "Succeeded" : "Failed") +
                '</parameter>';

            commentTypeNodes = document.getElementsByName("comment_type[" + itemIdx + "]");
            commentIdNodes = document.getElementsByName("comment_id[" + itemIdx + "]");

            for (var i = 0; i < commentTypeNodes.length; i++) {
                content = content + '<parameter name="CommentType' +
                    commentIdNodes[i].value + '">' +
                    commentTypeNodes[i].value + '</parameter>';
            }

            content = content + "</parameters>" + "</request>";

            // Send the AJAX request
            sendRequest(content,
                function (result, respXML) {
                    // operation succeeded
                    // TODO: Some changes to here
                    hideRow("placeAppealResponse_" + itemIdx);
                    alterComment(itemIdx);
                    alterScore(respXML.getElementsByTagName("result")[0]);
                    
                    handleEventOfAppealResponse(reviewId);
                },
                function (result, respXML) {
                    // operation failed, alert the error message to the user
                    alert("An error occured while resolving the appeal: " + result);
                }
            );
        }

        /**
         * TODO: Document it
         */
        function hideRow(rowId) {
            if (document != null && document.getElementById != null) {
                var row = document.getElementById(rowId);
                if (row != null) row.style.display = "none";
            }
        }

        /**
         * TODO: Document it
         */
        function alterComment(itemIdx) {
            var commentTypeNodes = document.getElementsByName("comment_type[" + itemIdx + "]");
            var commentTextNodes = document.getElementsByName("cmtTypeStatic_" + itemIdx);
            if (commentTypeNodes == null || commentTextNodes == null) {
                return;
            }

            for (var i = 0; i < commentTypeNodes.length; i++) {
                var text = commentTypeNodes[i].options[commentTypeNodes[i].selectedIndex].value;

                commentTextNodes[i].innerHTML = text;
                commentTypeNodes[i].style.display = "none";
                commentTextNodes[i].style.display = "inline";
        }
        }

        /**
         * TODO: Document it
         */
        function alterScore(resultNode) {
            if (document == null || document.getElementById == null) {
                return;
            }

            var newScore = parseFloat(dojo.dom.textContent(resultNode));
            var newScoreNormalized = Math.round(newScore * 100);

            var scoreWhole = Math.floor(newScoreNormalized / 100);
            var scoreFrac = newScoreNormalized % 100;

            if (scoreFrac % 10 == 0) {
                scoreFrac = Math.floor(scoreFrac / 10);
            }

            var scoreEl = document.getElementById("scoreHere");
            if (scoreEl != null) scoreEl.innerHTML = scoreWhole.toString() + "." + scoreFrac.toString();
        }

        // TODO: Make the following code reusable with editReview.jsp

        // The "passed_tests" and "all_tests" inputs should be populated
        // by the values taken from appropriate hidden "answer" input
        dojo.addOnLoad(function () {
            var passedTestsNodes = document.getElementsByName("passed_tests");
            for (var i = 0; i < passedTestsNodes.length; i++) {
                var allTestsNode = getChildByName(passedTestsNodes[i].parentNode, "all_tests");
                var answerNode = getChildByNamePrefix(passedTestsNodes[i].parentNode, "answer[");
                var parts = answerNode.value.split("/");
                if (parts && parts.length >= 2) {
                    passedTestsNodes[i].value = parts[0];
                    allTestsNode.value = parts[1];
                }
            }
        });

        /**
         * TODO: Document it
         */
        function focusControl(ctrlId) {
            if (document != null && document.getElementById != null) {
                var ctrl = document.getElementById(ctrlId);
                if (ctrl != null && ctrl.focus != null) ctrl.focus();
            }
        }
    </script>

</head>

<body>
<div align="center">
    
    <div class="maxWidthBody" align="left">

        <jsp:include page="/includes/inc_header.jsp" />
        
        <jsp:include page="/includes/project/project_tabs.jsp" />
        
            <div id="mainMiddleContent">
                <div style="position: relative; width: 100%;">

                    <jsp:include page="/includes/review/review_project.jsp" />
                    <jsp:include page="/includes/review/review_table_title.jsp" />

                    <%-- Note, that the form is a "dummy" one, only needed to support Struts tags inside of it --%>
                    <s:set var="actionName">View${fn:replace(reviewType, ' ', '')}?rid=${review.id}</s:set>
                    <s:form action="%{#actionName}" namespace="/actions">

                    <c:set var="itemIdx" value="0" />
                    <table class="scorecard" cellpadding="0" width="100%" style="border-collapse: collapse;" id="table2">
                        <c:forEach items="${scorecardTemplate.allGroups}" var="group" varStatus="groupStatus">
                            <tr>
                                <td class="title" colspan="${canPlaceAppeal ? 5 : (canPlaceAppealResponse ? 4 : 3)}">
                                    ${orfn:htmlEncode(group.name)} &#xA0;
                                    (${orfn:displayScore(pageContext.request, group.weight)})</td>
                            </tr>
                            <c:forEach items="${group.allSections}" var="section" varStatus="sectionStatus">
                                <tr>
                                    <td class="subheader" width="100%">
                                        ${orfn:htmlEncode(section.name)} &#xA0;
                                        (${orfn:displayScore(pageContext.request, section.weight)})</td>
                                    <td class="subheader" align="center" width="49%"><or:text key="editReview.SectionHeader.Weight" /></td>
                                    <td class="subheader" align="center" width="1%"><or:text key="editReview.SectionHeader.Response" /></td>
                                    <c:if test="${canPlaceAppeal or canPlaceAppealResponse}">
                                        <td class="subheader" align="center" width="1%"><or:text key="editReview.SectionHeader.AppealStatus" /></td>
                                    </c:if>
                                    <c:if test="${canPlaceAppeal}">
                                        <td class="subheader" align="center" width="1%"><or:text key="editReview.SectionHeader.Appeal" /></td>
                                    </c:if>
                                </tr>
                                <c:forEach items="${section.allQuestions}" var="question" varStatus="questionStatus">
                                    <c:set var="item" value="${review.allItems[itemIdx]}" />

                                    <tr class="light">
                                        <%@ include file="../includes/review/review_question.jsp" %>
                                        <%@ include file="../includes/review/review_static_answer.jsp" %>
                                        <c:if test="${canPlaceAppeal or canPlaceAppealResponse}">
                                            <td class="valueC">${appealStatuses[itemIdx]}<!-- @ --></td>
                                        </c:if>
                                        <c:if test="${canPlaceAppeal}">
                                            <c:if test="${not empty appealStatuses[itemIdx]}">
                                                <td class="value"><!-- @ --></td>
                                            </c:if>
                                            <c:if test="${empty appealStatuses[itemIdx]}">
                                                <td class="valueC">
                                                    <a class="showText" id="placeAppeal_${itemIdx}"
                                                        href="javascript:toggleDisplay('appealText_${itemIdx}');toggleDisplay('placeAppeal_${itemIdx}');focusControl('appealArea_${itemIdx}');"><img
                                                        src="<or:text key='editReview.Button.Appeal.img' />" alt="<or:text key='editReview.Button.Appeal.alt' />" /></a>
                                                </td>
                                            </c:if>
                                        </c:if>
                                    </tr>
                                    <%@ include file="../includes/review/review_comments.jsp" %>
                                    <c:if test="${canPlaceAppeal and (empty appealStatuses[itemIdx])}">
                                        <tr class="highlighted">
                                            <td class="value" colspan="6">
                                                <div id="appealText_${itemIdx}" class="hideText">
                                                    <b><or:text key="editReview.Question.AppealText.title"/>:</b><br />
                                                    <textarea id="appealArea_${itemIdx}" name="appeal_text[${itemIdx}]" rows="2" cols="20" style="font-size:10px;font-family:sans-serif;width:99%;height:50px;border:1px solid #ccc;margin:3px;"></textarea><br />
                                                    <a href="javascript:placeAppeal(${itemIdx}, ${item.id}, ${review.id});"><img
                                                        src="<or:text key='editReview.Button.SubmitAppeal.img' />" alt="<or:text key='editReview.Button.SubmitAppeal.alt' />"
                                                        border="0" hspace="5" vspace="9" /></a><br />
                                                </div>
                                            </td>
                                        </tr>
                                    </c:if>
                                    <c:if test="${canPlaceAppealResponse and (appealStatuses[itemIdx] == 'Unresolved')}">
                                        <tr id="placeAppealResponse_${itemIdx}" class="highlighted">
                                            <td class="value" colspan="3">
                                                <b><or:text key="editReview.Question.AppealResponseText.title"/>:</b><br />
                                                <textarea rows="2" name="appeal_response_text[${itemIdx}]" cols="20" style="font-size:10px;font-family:sans-serif;width:99%;height:50px;border:1px solid #ccc;margin:3px;"></textarea><br />
                                                <input type="checkbox" name="appeal_response_success[${itemIdx}]" />
                                                <or:text key="editReview.Question.AppealSucceeded.title" />
                                            </td>
                                            <td class="value">
                                                <or:text key="editReview.Question.ModifiedResponse.title"/>:<br />
                                                <%@ include file="../includes/review/review_answer.jsp" %><br /><br />
                                                <a href="javascript:placeAppealResponse(${itemIdx}, ${item.id}, ${review.id});"><img
                                                    src="<or:text key='editReview.Button.SubmitAppealResponse.img' />"
                                                    alt="<or:text key='editReview.Button.SubmitAppealResponse.alt' />" border="0"/></a>
                                            </td>
                                        </tr>
                                    </c:if>

                                    <c:set var="itemIdx" value="${itemIdx + 1}" />
                                </c:forEach>
                            </c:forEach>
                            <c:if test="${groupStatus.index == scorecardTemplate.numberOfGroups - 1}">
                                <c:if test="${not empty review.score}">
                                    <tr>
                                        <td class="header"><!-- @ --></td>
                                        <td class="headerC"><or:text key="editReview.SectionHeader.Total" /></td>
                                        <td class="headerC" colspan="${canPlaceAppeal ? 3 : (canPlaceAppealResponse ? 2 : 1)}"><!-- @ --></td>
                                    </tr>
                                    <tr>
                                        <td class="value"><!-- @ --></td>
                                        <td class="valueC" nowrap="nowrap"><b id="scoreHere">${orfn:displayScore(pageContext.request, review.score)}</b></td>
                                        <td class="valueC"><!-- @ --></td>
                                        <c:if test="${canPlaceAppeal or canPlaceAppealResponse}">
                                            <td class="value"><!-- @ --></td>
                                        </c:if>
                                        <c:if test="${canPlaceAppeal}">
                                            <td class="value"><!-- @ --></td>
                                        </c:if>
                                    </tr>
                                </c:if>
                                <tr>
                                    <td class="lastRowTD" colspan="${canPlaceAppeal ? 5 : (canPlaceAppealResponse ? 4 : 3)}"><!-- @ --></td>
                                </tr>
                            </c:if>
                        </c:forEach>
                    </table><br />
                    </s:form>

                    <div align="right">
                        <c:if test="${isPreview}">
                            <a href="javascript:window.close();"><img src="<or:text key='btnClose.img' />" alt="<or:text key='btnClose.alt' />" border="0" /></a>
                        </c:if>
                        <c:if test="${not isPreview}">
                            <a href="<or:url value='/actions/ViewProjectDetails?pid=${project.id}' />">
                                <img src="<or:text key='btnBack.img' />" alt="<or:text key='btnBack.alt' />" border="0" /></a>
                        </c:if>
                        <br />
                    </div>

                </div>
            </div>
        
        <jsp:include page="/includes/inc_footer.jsp" />

    </div>

</div>

</body>
</html>
