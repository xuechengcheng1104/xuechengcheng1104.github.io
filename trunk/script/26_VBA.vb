
'##################################################
'#    WriteUtf8
'##################################################
Function WriteUtf8(ByVal filename As String, ByVal content As String)
    Dim tempFilename As String
    tempFilename = filename & ".temp"
    ' 将字符写入utf8编码的临时文件
    Dim WriteStream As Object
    Set WriteStream = CreateObject("ADODB.Stream")
    With WriteStream
        .Type = 2               'adTypeText
        .CharSet = "UTF-8"
        .Open
        .WriteText content
        .SaveToFile tempFilename, 2  'adSaveCreateOverWrite
        .Flush
        .Close
    End With
    Set WriteStream = Nothing
    ' 去除BOM头
    Call Utf8WithoutBom(tempFilename, filename)
    ' 删除临时文件
    Kill tempFilename
End Function
'##################################################
'#    Utf8WithoutBom
'##################################################
' 去除BOM头
Function Utf8WithoutBom(ByVal getPath As String, ByVal putPath As String)
    Dim getFileNum As Integer
    Dim putFileNum As Integer
    getFileNum = 1
    putFileNum = 2
    Open getPath For Binary As #getFileNum
    Open putPath For Binary As #putFileNum
    Dim fileByte As Byte
    Seek #getFileNum, 4
    For i = 1 To LOF(getFileNum) - 3
        Get #getFileNum, , fileByte
        Put #putFileNum, , fileByte
    Next i
    Close #getFileNum
    Close #putFileNum
End Function
'##################################################
'#    coordinator
'##################################################
Sub coordinator()
'
  Application.ScreenUpdating = False
  Dim path_name As String
  Dim coordinator_name As String
  Dim properties_name As String
  Dim runjob_name As String
  Dim MyFile As Object
  Dim objFile, stmFile As Object
  Dim strText As String
  Sheets("home").Select
  root_path = Cells(4, 7) & "\"
  version_path = root_path & Cells(3, 7) & "\"
  python_path = root_path & "Public\python"
  Set MyFile = CreateObject("Scripting.FileSystemObject")
  Sheets("coordinator").Select
  arr = Range("A1").CurrentRegion
  For i = 2 To UBound(arr)
    Sheets("coordinator").Select
    level_path = Cells(i, 1) & "\"
    coord_path = Cells(i, 3) & "\"
    queue_name = "queue02"
    level_name = Cells(i, 1)
    coord_name = Cells(i, 3)
    job_start = Cells(i, 8)
    job_end = Cells(i, 9)
    If Dir(version_path & level_path, vbDirectory) = "" Then
        MkDir version_path & level_path
    End If
    '1. ###### 判断coordinator.xml、cfbdm.properties、runJob.sh是否存在 ######
    path_name = version_path & level_path & coord_path
    coordinator_name = path_name & "coordinator.xml"
    properties_name = path_name & "cfbdm.properties"
    runjob_name = path_name & "runJob.sh"
    If Dir(path_name, vbDirectory) <> "" Then
      If MyFile.FileExists(coordinator_name) = True Then
          Kill (coordinator_name)
      End If
    Else
      MkDir path_name
    End If
    If Dir(path_name, vbDirectory) <> "" Then
      If MyFile.FileExists(properties_name) = True Then
          Kill (properties_name)
      End If
    Else
      MkDir path_name
    End If
    If Dir(path_name, vbDirectory) <> "" Then
      If MyFile.FileExists(runjob_name) = True Then
          Kill (runjob_name)
      End If
    Else
      MkDir path_name
    End If
    MyFile.CopyFolder python_path, path_name
    '1. ##############################################
    '2. ###### 生成coordinator.xml文件 ######
    Open coordinator_name For Append As #1
    Print #1, "<coordinator-app name=""" & Cells(i, 3) & """" & Chr(10);
    If Cells(i, 7) = "day" Then
        Print #1, Chr(9) & "frequency=""${coord:days(1)}"" start=""${job_start}"" end=""${job_end}""" & Chr(10);
    ElseIf Cells(i, 7) = "week" Then
        Print #1, Chr(9) & "frequency=""${coord:days(7)}"" start=""${job_start}"" end=""${job_end}""" & Chr(10);
    ElseIf Cells(i, 7) = "month" Then
        Print #1, Chr(9) & "frequency=""${coord:months(1)}"" start=""${job_start}"" end=""${job_end}""" & Chr(10);
    ElseIf Cells(i, 7) = "quarter" Then
        Print #1, Chr(9) & "frequency=""${coord:months(3)}"" start=""${job_start}"" end=""${job_end}""" & Chr(10);
    ElseIf Cells(i, 7) = "year" Then
        Print #1, Chr(9) & "frequency=""${coord:months(12)}"" start=""${job_start}"" end=""${job_end}""" & Chr(10);
    End If
    Print #1, Chr(9) & "timezone=""GMT+08:00"" xmlns=""uri:oozie:coordinator:0.2"">" & Chr(10);
    Print #1, "  " & Chr(10);
    Print #1, "  <controls>" & Chr(10);
    Print #1, "    <concurrency>1</concurrency>" & Chr(10);
    Print #1, "  </controls>" & Chr(10);
    Print #1, "  " & Chr(10);
    '2.1 ###### 为多个上游作业依赖而设计 ######
    j = 0
    If Cells(i, 4) <> "" Then
      Print #1, "  <datasets>" & Chr(10);
      Do
        If Cells(i, 7) = "day" Then
            Print #1, "    <dataset name=""input" & (j + 1) & "_data"" frequency=""${coord:days(1)}""" & Chr(10);
        ElseIf Cells(i, 7) = "week" Then
            Print #1, "    <dataset name=""input" & (j + 1) & "_data"" frequency=""${coord:days(7)}""" & Chr(10);
        ElseIf Cells(i, 7) = "month" Then
            Print #1, "    <dataset name=""input" & (j + 1) & "_data"" frequency=""${coord:months(1)}""" & Chr(10);
        ElseIf Cells(i, 7) = "quarter" Then
            Print #1, "    <dataset name=""input" & (j + 1) & "_data"" frequency=""${coord:months(3)}""" & Chr(10);
        ElseIf Cells(i, 7) = "year" Then
            Print #1, "    <dataset name=""input" & (j + 1) & "_data"" frequency=""${coord:months(12)}""" & Chr(10);
        End If
        Print #1, Chr(9) & Chr(9) & "initial-instance=""${job_start}"" timezone=""GMT+08:00"">" & Chr(10);
        Print #1, "      <uri-template>${namenode_address}/apps-data/hduser0301/" & Cells(i, 6) & "/" & Cells(i, 5) & "/" & Cells(i, 4) & "</uri-template>" & Chr(10);
        Print #1, "      <done-flag></done-flag>" & Chr(10);
        Print #1, "    </dataset>" & Chr(10);
        i = i + 1
        j = j + 1
      Loop While Cells(i, 3) <> "" And Cells(i - 1, 3) = Cells(i, 3)
      Print #1, "  </datasets>" & Chr(10);
      Print #1, "  " & Chr(10);
      Print #1, "  <input-events>" & Chr(10);
      For k = 1 To j
          Print #1, "    <data-in name=""input" & k & """ dataset=""input" & k & "_data"">" & Chr(10);
          Print #1, "      <instance>${coord:current(0)}</instance>" & Chr(10);
          Print #1, "    </data-in>" & Chr(10);
      Next
      Print #1, "  </input-events>" & Chr(10);
      Print #1, "  " & Chr(10);
      i = i - 1
    End If
    '2.1 ###############################
    Print #1, "  <action>" & Chr(10);
    Print #1, "    <workflow>" & Chr(10);
    Print #1, "      <app-path>${application_path}</app-path>" & Chr(10);
    Print #1, "      <configuration>" & Chr(10);
    Print #1, "        <property>" & Chr(10);
    Print #1, "          <name>nominalformatDate</name>" & Chr(10);
    Print #1, "          <value>${coord:formatTime(coord:nominalTime(),""yyyy-MM-dd"")}</value>" & Chr(10);
    Print #1, "        </property>" & Chr(10);
    Print #1, "        <property>" & Chr(10);
    Print #1, "          <name>user_name</name>" & Chr(10);
    Print #1, "          <value>${coord:user()}</value>" & Chr(10);
    Print #1, "        </property>" & Chr(10);
    Print #1, "        <property>" & Chr(10);
    Print #1, "          <name>nominal_date</name>" & Chr(10);
    Print #1, "          <value>${coord:formatTime(coord:dateOffset(coord:nominalTime(),-1,'DAY'),""yyyy-MM-dd"")}</value>" & Chr(10);
    Print #1, "        </property>" & Chr(10);
    Print #1, "        <property>" & Chr(10);
    Print #1, "          <name>keep_date</name>" & Chr(10);
    Print #1, "          <value>${coord:formatTime(coord:dateOffset(coord:nominalTime(),-8,'DAY'),""yyyy-MM-dd"")}</value>" & Chr(10);
    Print #1, "        </property>" & Chr(10);
    Print #1, "      </configuration>" & Chr(10);
    Print #1, "    </workflow>" & Chr(10);
    Print #1, "  </action>" & Chr(10);
    Print #1, "  " & Chr(10);
    Print #1, "</coordinator-app>" & Chr(10);
    Close #1
    Set objFile = CreateObject("Scripting.FileSystemObject")
    Set stmFile = objFile.OpenTextFile(coordinator_name, 1, False)
    strText = stmFile.ReadAll
    stmFile.Close
    Call WriteUtf8(coordinator_name, strText)
    '2. ######################################
    '3. ###### 生成runjob.sh文件 ######
    Open runjob_name For Append As #2
    Print #2, "#!/bin/bash" & Chr(10);
    Print #2, "" & Chr(10);
    Print #2, "workflow_info=`oozie validate workflow.xml`" & Chr(10);
    Print #2, "coordinator_info=`oozie validate coordinator.xml`" & Chr(10);
    Print #2, "" & Chr(10);
    Print #2, "if [ ""$workflow_info"" != ""Valid worflow-app"" ]; then" & Chr(10);
    Print #2, "  exit 1" & Chr(10);
    Print #2, "fi" & Chr(10);
    Print #2, "" & Chr(10);
    Print #2, "if [ ""$coordinator_info"" != ""Valid worflow-app"" ]; then" & Chr(10);
    Print #2, "  exit 1" & Chr(10);
    Print #2, "fi" & Chr(10);
    Print #2, "" & Chr(10);
    Print #2, "hadoop dfs -rmr /apps/hduser0301/" & Cells(i, 1) & "/" & Cells(i, 3) & Chr(10);
    Print #2, "" & Chr(10);
    Print #2, "hadoop dfs -put ./ /apps/hduser0301/" & Cells(i, 1) & "/" & Cells(i, 3) & Chr(10);
    Print #2, "" & Chr(10);
    Print #2, "oozie -Dheader:j_username=V_PA011_HADOOP_CORE -Dheader:j_password={DES}CJxT1NZKkAcAaIgXL1mcSA== \" & Chr(10);
    Print #2, "job --oozie http://cnsh041567.app.paic.com.cn:8080/oozie -config ./cfbdm.properties \" & Chr(10);
    Print #2, "-auth ldap -run -doas hduser0301" & Chr(10);
    Close #2
    Set objFile = CreateObject("Scripting.FileSystemObject")
    Set stmFile = objFile.OpenTextFile(runjob_name, 1, False)
    strText = stmFile.ReadAll
    stmFile.Close
    Call WriteUtf8(runjob_name, strText)
    '3. #################################
    Sheets("coor_properties").Select
    '4. ###### 生成cfbdm.properties文件 ######
    arr1 = Range("A1").CurrentRegion
    Open properties_name For Append As #3
    For p = 1 To UBound(arr1)
        If Cells(p, 1) <> "########" Then
            Print #3, Cells(p, 1) & Replace(Replace(Replace(Replace(Replace(Cells(p, 2), "<level_name>", level_name), "<coord_name>", coord_name), "<job_start>", job_start), "<job_end>", job_end), "<queue_name>", queue_name) & Chr(10);
        Else
            Print #3, "  " & Chr(10);
            Print #3, "  " & Chr(10);
        End If
    Next
    Close #3
    Set objFile = CreateObject("Scripting.FileSystemObject")
    Set stmFile = objFile.OpenTextFile(properties_name, 1, False)
    strText = stmFile.ReadAll
    stmFile.Close
    Call WriteUtf8(properties_name, strText)
    '4. ######################################
  Next
    Sheets("home").Select
    MsgBox "测试验收-定时作业已经生成！"
End Sub
'##################################################
'#    sqoop_import
'##################################################
Sub sqoop_import()
'
  Application.ScreenUpdating = False
  Dim path_name As String
  Dim workflow_name As String
  Dim MyFile As Object
  Dim objFile, stmFile As Object
  Dim strText As String
  Sheets("home").Select
  root_path = Cells(4, 7) & "\"
  version_path = root_path & Cells(3, 7) & "\"
  Set MyFile = CreateObject("Scripting.FileSystemObject")
  Sheets("sqoop_import").Select
  arr = Range("A1").CurrentRegion

  For i = 2 To UBound(arr)
    Sheets("sqoop_import").Select
    level_path = Cells(i, 1) & "\"
    coord_path = Cells(i, 1) & "_" & Cells(i, 2) & "_cd\"
    If Dir(version_path & level_path, vbDirectory) = "" Then
        MkDir version_path & level_path
    End If
    '1. ###### 判断workflow.xml是否存在 ######
    path_name = version_path & level_path & coord_path
    workflow_name = path_name & "workflow.xml"
    If Dir(path_name, vbDirectory) <> "" Then
      If MyFile.FileExists(workflow_name) = True Then
          Kill (workflow_name)
      End If
    Else
      MkDir path_name
    End If
    '1. ##########################################
    '2. ###### 生成workflow.xml文件 ######
    j = i
    m = 0
    Do
        Do
            i = i + 1
        Loop While Cells(i, 6) <> "" And Cells(i - 1, 6) = Cells(i, 6)
        m = m + 1
    Loop While Cells(i, 3) <> "" And Cells(i - 1, 3) = Cells(i, 3)
    i = i - 1
    Open workflow_name For Append As #1
    Print #1, "<workflow-app xmlns=""uri:oozie:workflow:0.2"" name=""" & Cells(i, 3) & """>" & Chr(10);
    Print #1, "  " & Chr(10);
    Print #1, "  <start to=""forkSubWorkflows"" />" & Chr(10);
    Print #1, "  " & Chr(10);
    Print #1, "  <fork name=""forkSubWorkflows"">" & Chr(10);
    For n = 1 To m
        Print #1, "    <path start=""decision" & n & """ />" & Chr(10);
    Next
    Print #1, "  </fork>" & Chr(10);
    Print #1, "  " & Chr(10);
    n = 1
    For k = j To i
        Do While Cells(k - 1, 6) <> Cells(k, 6)
            Print #1, "  <decision name=""decision" & n & """>" & Chr(10);
            Print #1, "    <switch>" & Chr(10);
            Print #1, "      <case to=""joining"">${fs:isDir(concat(""/apps-data/hduser0301/" & Cells(k, 1) & "/" & Cells(k, 1) & "_" & Cells(k, 2) & "_cd/" & UCase(Cells(k, 9)) & "/s_""" & ",nominalformatDate))}</case>" & Chr(10);
            Print #1, "      <default to=""" & Cells(k, 9) & """ />" & Chr(10);
            Print #1, "    </switch>" & Chr(10);
            Print #1, "  </decision>" & Chr(10);
            Print #1, "  " & Chr(10);
            Print #1, "  <action name=""" & Cells(k, 9) & """>" & Chr(10);
            Print #1, "    <sqoop xmlns=""uri:oozie:sqoop-action:0.2"">" & Chr(10);
            Print #1, "      <job-tracker>${jobtracker_address}</job-tracker>" & Chr(10);
            Print #1, "      <name-node>${namenode_address}</name-node>" & Chr(10);
            Print #1, "      <prepare>" & Chr(10);
            Print #1, "        <delete path=""${hdfs_address_prefix}/" & Cells(k, 5) & "." & Cells(k, 6) & """ />" & Chr(10);
            Print #1, "      </prepare>" & Chr(10);
            Print #1, "      <configuration>" & Chr(10);
            Print #1, "        <property>" & Chr(10);
            Print #1, "          <name>mapred.job.queue.name</name>" & Chr(10);
            Print #1, "          <value>${mapred_job_queue_name}</value>" & Chr(10);
            Print #1, "        </property>" & Chr(10);
            Print #1, "        <property>" & Chr(10);
            Print #1, "          <name>pa.oozie.password.indexs</name>" & Chr(10);
            Print #1, "          <value>6</value>" & Chr(10);
            Print #1, "        </property>" & Chr(10);
            Print #1, "      </configuration>" & Chr(10);
            Print #1, "      <arg>import</arg>" & Chr(10);
            Print #1, "      <arg>${" & LCase(Cells(k, 4)) & "_db_jdbc}</arg>" & Chr(10);
            Print #1, "      <arg>--username</arg>" & Chr(10);
            Print #1, "      <arg>${" & LCase(Cells(k, 4)) & "_db_username}</arg>" & Chr(10);
            Print #1, "      <arg>--password</arg>" & Chr(10);
            Print #1, "      <arg>${" & LCase(Cells(k, 4)) & "_db_password}</arg>" & Chr(10);
            Print #1, "      <arg>--table</arg>" & Chr(10);
            Print #1, "      <arg>" & Cells(k, 5) & "." & Cells(k, 6) & "</arg>" & Chr(10);
            Print #1, "      <arg>--columns</arg>" & Chr(10);
            '2.1 ###### 获取源表的字段列表 ######
            Dim Columns As String
            Columns = ""
            Do
                If Columns <> "" Then
                    Columns = Columns + "," + Cells(k, 7)
                Else
                    Columns = Columns + Cells(k, 7)
                End If
                k = k + 1
            Loop While Cells(k, 6) <> "" And Cells(k - 1, 6) = Cells(k, 6)
            k = k - 1
            Print #1, "      <arg>" & Columns & "</arg>" & Chr(10);
            '2.1 ################################
            Print #1, "      <arg>-m</arg>" & Chr(10);
            Print #1, "      <arg>1</arg>" & Chr(10);
            Print #1, "      <arg>--fields-terminated-by</arg>" & Chr(10);
            Print #1, "      <arg>\001</arg>" & Chr(10);
            Print #1, "      <arg>--lines-terminated-by</arg>" & Chr(10);
            Print #1, "      <arg>\n</arg>" & Chr(10);
            Print #1, "      <arg>--hive-drop-import-delims</arg>" & Chr(10);
            Print #1, "      <arg>--null-string</arg>" & Chr(10);
            Print #1, "      <arg>\\N</arg>" & Chr(10);
            Print #1, "      <arg>--null-non-string</arg>" & Chr(10);
            Print #1, "      <arg>\\N</arg>" & Chr(10);
            Print #1, "      <arg>--hive-import</arg>" & Chr(10);
            Print #1, "      <arg>--hive-overwrite</arg>" & Chr(10);
            Print #1, "      <arg>--hive-table</arg>" & Chr(10);
            Print #1, "      <arg>" & LCase(Cells(k, 8)) & "." & LCase(Cells(k, 9)) & "</arg>" & Chr(10);
            Print #1, "    </sqoop>" & Chr(10);
            Print #1, "    <ok to=""create_path" & n & """ />" & Chr(10);
            Print #1, "    <error to=""fail"" />" & Chr(10);
            Print #1, "  </action>" & Chr(10);
            Print #1, "  " & Chr(10);
            Print #1, "  <action name=""create_path" & n & """>" & Chr(10);
            Print #1, "    <fs>" & Chr(10);
            Print #1, "      <mkdir path=""" & "${namenode_address}/apps-data/hduser0301/" & Cells(k, 1) & "/" & Cells(k, 1) & "_" & Cells(k, 2) & "_cd/" & UCase(Cells(k, 9)) & "/s_${nominalformatDate}/" & """ />" & Chr(10);
            Print #1, "    </fs>" & Chr(10);
            Print #1, "    <ok to=""joing"" />" & Chr(10);
            Print #1, "    <error to=""fail"" />" & Chr(10);
            Print #1, "  </action>" & Chr(10);
            Print #1, "  " & Chr(10);
            n = n + 1
            Exit Do
        Loop
    Next
    Print #1, "  <join name=""joining"" to=""end"" />" & Chr(10);
    Print #1, "  " & Chr(10);
    Print #1, "  <kill name=""fail"">" & Chr(10);
    Print #1, "    <message>" & Cells(i, 3) & " workflow failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>" & Chr(10);
    Print #1, "  </kill>" & Chr(10);
    Print #1, "  " & Chr(10);
    Print #1, "  <end name=""end"" />" & Chr(10);
    Print #1, "  " & Chr(10);
    Print #1, "</workflow-app>" & Chr(10);
    Close #1
    Set objFile = CreateObject("Scripting.FileSystemObject")
    Set stmFile = objFile.OpenTextFile(workflow_name, 1, False)
    strText = stmFile.ReadAll
    stmFile.Close
    Call WriteUtf8(workflow_name, strText)
    '2. ##################################
  Next
    Sheets("home").Select
    MsgBox "测试验收-导数作业已经生成！"
End Sub
'##################################################
'#    Utf8WithoutBom
'##################################################
Sub shell_hive()
'
  Application.ScreenUpdating = False
  Dim path_name As String
  Dim workflow_name As String
  Dim MyFile As Object
  Dim objFile, stmFile As Object
  Dim strText As String
  Sheets("home").Select
  root_path = Cells(4, 7) & "\"
  version_path = root_path & Cells(3, 7) & "\"
  Set MyFile = CreateObject("Scripting.FileSystemObject")
  Sheets("shell_hive").Select
  arr = Range("A1").CurrentRegion
  For i = 2 To UBound(arr)
    Sheets("shell_hive").Select
    level_path = Cells(i, 1) & "\"
    coord_path = Cells(i, 1) & "_" & Cells(i, 2) & "_cd\"
    If Dir(version_path & level_path, vbDirectory) = "" Then
        MkDir version_path & level_path
    End If
    '1. ###### 判断workflow.xml是否存在 ######
    path_name = version_path & level_path & coord_path
    workflow_name = path_name & "workflow.xml"
    If Dir(path_name, vbDirectory) <> "" Then
      If MyFile.FileExists(workflow_name) = True Then
          Kill (workflow_name)
      End If
    Else
      MkDir path_name
    End If
    '1. ##########################################
    '2. ###### 生成workflow.xml文件 ######
    j = i
    Do
        i = i + 1
    Loop While Cells(i, 3) <> "" And Cells(i - 1, 3) = Cells(i, 3)
    i = i - 1
    Open workflow_name For Append As #1
    Print #1, "<workflow-app xmlns=""uri:oozie:workflow:0.2"" name=""" & Cells(j, 3) & """>" & Chr(10);
    Print #1, "  " & Chr(10);
    Print #1, "  <start to=""forkSubWorkflows"" />" & Chr(10);
    Print #1, "  " & Chr(10);
    Print #1, "  <fork name=""forkSubWorkflows"">" & Chr(10);
    If Cells(i, 1) = "xt_cfbdm_s_o" Then
        n = 1
        For k = j To i Step 2
        Print #1, "    <path start=""decision" & n & """ />" & Chr(10);
        n = n + 1
        Next
    Else
        n = 1
        For k = j To i
        Print #1, "    <path start=""decision" & n & """ />" & Chr(10);
        n = n + 1
        Next
    End If
    Print #1, "  </fork>" & Chr(10);
    Print #1, "  " & Chr(10);
    n = 1
    For k = j To i
        Print #1, "  <decision name=""decision" & n & """>" & Chr(10);
        Print #1, "    <switch>" & Chr(10);
        If Cells(k, 1) = "xt_cfbdm_s_o" Then
            Print #1, "      <case to=""joining"">${fs:isDir(concat(""/apps-data/hduser0301/" & Cells(k, 1) & "/" & Cells(k, 1) & "_" & Cells(k, 2) & "_cd/" & UCase(Cells(k + 1, 5)) & "/o_""" & ",nominalformatDate))}</case>" & Chr(10);
        ElseIf Cells(k, 1) = "xt_cfbdm_o_l" Then
            Print #1, "      <case to=""joining"">${fs:isDir(concat(""/apps-data/hduser0301/" & Cells(k, 1) & "/" & Cells(k, 1) & "_" & Cells(k, 2) & "_cd/" & UCase(Cells(k, 5)) & "/l_""" & ",nominalformatDate))}</case>" & Chr(10);
        ElseIf Cells(k, 1) = "xt_cfbdm_l_d" Then
            Print #1, "      <case to=""joining"">${fs:isDir(concat(""/apps-data/hduser0301/" & Cells(k, 1) & "/" & Cells(k, 1) & "_" & Cells(k, 2) & "_cd/" & UCase(Cells(k, 5)) & "/d_""" & ",nominalformatDate))}</case>" & Chr(10);
        End If
        Print #1, "      <default to=""" & Cells(k, 5) & """ />" & Chr(10);
        Print #1, "    </switch>" & Chr(10);
        Print #1, "  </decision>" & Chr(10);
        Print #1, "  " & Chr(10);
        If Cells(k, 1) = "xt_cfbdm_s_o" Then
            Print #1, "  <action name=""" & Cells(k, 5) & """>" & Chr(10);
            Print #1, "    <shell xmlns=""uri:oozie:shell-action:0.2"">" & Chr(10);
            Print #1, "      <job-tracker>${jobtracker_address}</job-tracker>" & Chr(10);
            Print #1, "      <name-node>${namenode_address}</name-node>" & Chr(10);
            Print #1, "      <configuration>" & Chr(10);
            Print #1, "        <property>" & Chr(10);
            Print #1, "          <name>mapred.job.queue.name</name>" & Chr(10);
            Print #1, "          <value>${mapred_job_queue_name}</value>" & Chr(10);
            Print #1, "        </property>" & Chr(10);
            Print #1, "      </configuration>" & Chr(10);
            Print #1, "      <exec>hive</exec>" & Chr(10);
            Print #1, "      <argument>-hiveconf</argument>" & Chr(10);
            Print #1, "      <argument>mapred.job.queue.name=${mapred_job_queue_name}</argument>" & Chr(10);
            Print #1, "      <argument>-hivevar</argument>" & Chr(10);
            Print #1, "      <argument>txdate=${nominal_date}</argument>" & Chr(10);
            Print #1, "      <argument>-f</argument>" & Chr(10);
            Print #1, "      <argument>" & Cells(k, 4) & "</argument>" & Chr(10);
            Print #1, "      <file>hql/" & Cells(k, 4) & "#" & Cells(k, 4) & "</file>" & Chr(10);
            Print #1, "    </shell>" & Chr(10);
            k = k + 1
            Print #1, "    <ok to=""" & Cells(k, 5) & """ />" & Chr(10);
            Print #1, "    <error to=""fail"" />" & Chr(10);
            Print #1, "  </action>" & Chr(10);
            Print #1, "  " & Chr(10);
            Print #1, "  <action name=""" & Cells(k, 5) & """>" & Chr(10);
            Print #1, "    <shell xmlns=""uri:oozie:shell-action:0.2"">" & Chr(10);
            Print #1, "      <job-tracker>${jobtracker_address}</job-tracker>" & Chr(10);
            Print #1, "      <name-node>${namenode_address}</name-node>" & Chr(10);
            Print #1, "      <configuration>" & Chr(10);
            Print #1, "        <property>" & Chr(10);
            Print #1, "          <name>mapred.job.queue.name</name>" & Chr(10);
            Print #1, "          <value>${mapred_job_queue_name}</value>" & Chr(10);
            Print #1, "        </property>" & Chr(10);
            Print #1, "      </configuration>" & Chr(10);
            Print #1, "      <exec>hive</exec>" & Chr(10);
            Print #1, "      <argument>-hiveconf</argument>" & Chr(10);
            Print #1, "      <argument>mapred.job.queue.name=${mapred_job_queue_name}</argument>" & Chr(10);
            Print #1, "      <argument>-hivevar</argument>" & Chr(10);
            Print #1, "      <argument>txdate=${nominal_date}</argument>" & Chr(10);
            Print #1, "      <argument>-f</argument>" & Chr(10);
            Print #1, "      <argument>" & Cells(k, 4) & "</argument>" & Chr(10);
            Print #1, "      <file>hql/" & Cells(k, 4) & "#" & Cells(k, 4) & "</file>" & Chr(10);
            Print #1, "    </shell>" & Chr(10);
            Print #1, "    <ok to=""create_path" & n & """ />" & Chr(10);
            Print #1, "    <error to=""fail"" />" & Chr(10);
            Print #1, "  </action>" & Chr(10);
            Print #1, "  " & Chr(10);
        Else
            Print #1, "  <action name=""" & Cells(k, 5) & """>" & Chr(10);
            Print #1, "    <shell xmlns=""uri:oozie:shell-action:0.2"">" & Chr(10);
            Print #1, "      <job-tracker>${jobtracker_address}</job-tracker>" & Chr(10);
            Print #1, "      <name-node>${namenode_address}</name-node>" & Chr(10);
            Print #1, "      <configuration>" & Chr(10);
            Print #1, "        <property>" & Chr(10);
            Print #1, "          <name>mapred.job.queue.name</name>" & Chr(10);
            Print #1, "          <value>${mapred_job_queue_name}</value>" & Chr(10);
            Print #1, "        </property>" & Chr(10);
            Print #1, "      </configuration>" & Chr(10);
            Print #1, "      <exec>hive</exec>" & Chr(10);
            Print #1, "      <argument>-hiveconf</argument>" & Chr(10);
            Print #1, "      <argument>mapred.job.queue.name=${mapred_job_queue_name}</argument>" & Chr(10);
            Print #1, "      <argument>-hivevar</argument>" & Chr(10);
            Print #1, "      <argument>txdate=${nominal_date}</argument>" & Chr(10);
            Print #1, "      <argument>-f</argument>" & Chr(10);
            Print #1, "      <argument>" & Cells(k, 4) & "</argument>" & Chr(10);
            Print #1, "      <file>hql/" & Cells(k, 4) & "#" & Cells(k, 4) & "</file>" & Chr(10);
            Print #1, "    </shell>" & Chr(10);
            Print #1, "    <ok to=""create_path" & n & """ />" & Chr(10);
            Print #1, "    <error to=""fail"" />" & Chr(10);
            Print #1, "  </action>" & Chr(10);
            Print #1, "  " & Chr(10);
        End If
        Print #1, "  <action name=""create_path" & n & """>" & Chr(10);
        Print #1, "    <fs>" & Chr(10);
        If Cells(i, 1) = "xt_cfbdm_s_o" Then
            Print #1, "      <mkdir path=""" & "${namenode_address}/apps-data/hduser0301/" & Cells(i, 1) & "/" & Cells(i, 1) & "_" & Cells(i, 2) & "_cd/" & UCase(Cells(k, 5)) & "/o_${nominalformatDate}/" & """ />" & Chr(10);
        ElseIf Cells(i, 1) = "xt_cfbdm_o_l" Then
            Print #1, "      <mkdir path=""" & "${namenode_address}/apps-data/hduser0301/" & Cells(i, 1) & "/" & Cells(i, 1) & "_" & Cells(i, 2) & "_cd/" & UCase(Cells(k, 5)) & "/l_${nominalformatDate}/" & """ />" & Chr(10);
        ElseIf Cells(i, 1) = "xt_cfbdm_l_d" Then
            Print #1, "      <mkdir path=""" & "${namenode_address}/apps-data/hduser0301/" & Cells(i, 1) & "/" & Cells(i, 1) & "_" & Cells(i, 2) & "_cd/" & UCase(Cells(k, 5)) & "/d_${nominalformatDate}/" & """ />" & Chr(10);
        End If
        Print #1, "    </fs>" & Chr(10);
        Print #1, "    <ok to=""joining"" />" & Chr(10);
        Print #1, "    <error to=""fail"" />" & Chr(10);
        Print #1, "  </action>" & Chr(10);
        Print #1, "  " & Chr(10);
        n = n + 1
    Next
        Print #1, "  <join name=""joining"" to=""end"" />" & Chr(10);
        Print #1, "  " & Chr(10);

        Print #1, "  <kill name=""fail"">" & Chr(10);
        Print #1, "    <message>" & Cells(i, 3) & " workflow failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>" & Chr(10);
        Print #1, "  </kill>" & Chr(10);
        Print #1, "  " & Chr(10);
        Print #1, "  <end name=""end"" />" & Chr(10);
        Print #1, "  " & Chr(10);
        Print #1, "</workflow-app>" & Chr(10);
        Close #1
        Set objFile = CreateObject("Scripting.FileSystemObject")
        Set stmFile = objFile.OpenTextFile(workflow_name, 1, False)
        strText = stmFile.ReadAll
        stmFile.Close
        Call WriteUtf8(workflow_name, strText)
    '2. ##################################
  Next
    Sheets("home").Select
    MsgBox "测试验收-修数作业已经生成！"
End Sub
'##################################################
'#    Utf8WithoutBom
'##################################################
Sub sqoop_export()
'
  Application.ScreenUpdating = False
  Dim path_name As String
  Dim shell_name As String
  Dim workflow_name As String
  Dim MyFile As Object
  Dim objFile, stmFile As Object
  Dim strText As String
  Sheets("home").Select
  root_path = Cells(4, 7) & "\"
  version_path = root_path & Cells(3, 7) & "\"
  Set MyFile = CreateObject("Scripting.FileSystemObject")
  Sheets("sqoop_export").Select
  arr = Range("A1").CurrentRegion
  For i = 2 To UBound(arr)
    Sheets("sqoop_export").Select
    level_path = Cells(i, 1) & "\"
    coord_path = Cells(i, 1) & "_" & Cells(i, 2) & "_cd\"
    If Dir(version_path & level_path, vbDirectory) = "" Then
        MkDir version_path & level_path
    End If
    '1. ###### 判断workflow.xml是否存在 ######
    path_name = version_path & level_path & coord_path
    workflow_name = path_name & "workflow.xml"
    If Dir(path_name, vbDirectory) <> "" Then
      If MyFile.FileExists(workflow_name) = True Then
          Kill (workflow_name)
      End If
    Else
      MkDir path_name
    End If
    '1. ##########################################
    '2. ###### 生成shell文件 ######
    j = i
    m = 0
    Do
        '2.1 ###### 获取源表、目标表的字段列表 ######
        Dim Source_Columns, Target_Columns As String
        Source_Columns = ""
        Target_Columns = ""
        Do
            If Source_Columns <> "" Then
                Source_Columns = Source_Columns + "," + LCase(Cells(i, 6))
            Else
                Source_Columns = Source_Columns + LCase(Cells(i, 6))
            End If
            If Target_Columns <> "" Then
                Target_Columns = Target_Columns + "," + LCase(Cells(i, 10))
            Else
                Target_Columns = Target_Columns + LCase(Cells(i, 10))
            End If
            i = i + 1
        Loop While Cells(i, 5) <> "" And Cells(i - 1, 5) = Cells(i, 5)
        i = i - 1
        '2.1 ################################
        shell_path = version_path & level_path & Cells(i, 1) & "_" & Cells(i, 2) & "_cd\shell\"
        shell_name = shell_path & "export_" & LCase(Cells(i, 5)) & ".sh"
        If Dir(shell_path, vbDirectory) <> "" Then
            If MyFile.FileExists(shell_name) = True Then
                Kill (shell_name)
            End If
        Else
            MkDir shell_path
        End If
        Open shell_name For Append As #1
        Print #1, "#!/bin/bash" & Chr(10);
        Print #1, "" & Chr(10);
        Print #1, "#1 export data from hive to hdfs directory" & Chr(10);
        Print #1, "hive -e """ & Chr(10);
        Print #1, "set mapred.job.queue.name=$5;" & Chr(10);
        Print #1, "insert overwrite directory '/apps-data/hduser0301/" & LCase(Cells(i, 4)) & "/" & LCase(Cells(i, 5)) & "'" & Chr(10);
        Print #1, "select " & Source_Columns & Chr(10);
        Print #1, "from " & LCase(Cells(i, 4)) & "." & LCase(Cells(i, 5)) & Chr(10);
        Print #1, "where dt='$1';""" & Chr(10);
        Print #1, "" & Chr(10);
        Print #1, "#2 clear target database table data" & Chr(10);
        Print #1, "sqoop eval \" & Chr(10);
        Print #1, "-Dmapred.job.queue.name=$5 \" & Chr(10);
        Print #1, "--connect $2 \" & Chr(10);
        Print #1, "--username $3 \" & Chr(10);
        Print #1, "--password $4 \" & Chr(10);
        Print #1, "-e ""delete from " & LCase(Cells(i, 8)) & "." & LCase(Cells(i, 9)) & " where to_char(" & LCase(Cells(i, 10)) & ",'yyyy-MM-dd')='$1'"";" & Chr(10);
        Print #1, "" & Chr(10);
        Print #1, "#3 export directory data to target database" & Chr(10);
        Print #1, "sqoop export \" & Chr(10);
        Print #1, "-Dmapred.job.queue.name=$5 \" & Chr(10);
        Print #1, "--connect $2 \" & Chr(10);
        Print #1, "--username $3 \" & Chr(10);
        Print #1, "--password $4 \" & Chr(10);
        Print #1, "--export-dir '/apps-data/hduser0301/" & LCase(Cells(i, 4)) & "/" & LCase(Cells(i, 5)) & "' \" & Chr(10);
        Print #1, "--verbose \" & Chr(10);
        Print #1, "--table " & LCase(Cells(i, 8)) & "." & LCase(Cells(i, 9)) & " \" & Chr(10);
        Print #1, "--columns " & Target_Columns & " \" & Chr(10);
        Print #1, "--input-fields-terminated-by '\001' \" & Chr(10);
        Print #1, "--input-lines-terminated-by '\n' \" & Chr(10);
        Print #1, "--input-null-string '\\N' \" & Chr(10);
        Print #1, "--input-null-non-string '\\N';" & Chr(10);
        Close #1
        Set objFile = CreateObject("Scripting.FileSystemObject")
        Set stmFile = objFile.OpenTextFile(shell_name, 1, False)
        strText = stmFile.ReadAll
        stmFile.Close
        Call WriteUtf8(shell_name, strText)
        i = i + 1
        m = m + 1
    Loop While Cells(i, 3) <> "" And Cells(i - 1, 3) = Cells(i, 3)
        i = i - 1
        '2. ####################################
    '3. ###### 生成workflow.xml文件 ######
    Open workflow_name For Append As #2
    Print #2, "<workflow-app xmlns=""uri:oozie:workflow:0.2"" name=""" & Cells(i, 3) & """>" & Chr(10);
    Print #2, "  " & Chr(10);
    Print #2, "  <start to=""forkSubWorkflows"" />" & Chr(10);
    Print #2, "  " & Chr(10);
    Print #2, "  <fork name=""forkSubWorkflows"">" & Chr(10);
    For n = 1 To m
        Print #2, "    <path start=""decision" & n & """ />" & Chr(10);
    Next
    Print #2, "  </fork>" & Chr(10);
    Print #2, "  " & Chr(10);
    n = 1
    For k = j To i
        Do While Cells(k - 1, 5) <> Cells(k, 5)
            Print #2, "  <decision name=""decision" & n & """>" & Chr(10);
            Print #2, "    <switch>" & Chr(10);
            Print #2, "      <case to=""joining"">${fs:isDir(concat(""/apps-data/hduser0301/" & Cells(k, 1) & "/" & Cells(k, 1) & "_" & Cells(k, 2) & "_cd/" & UCase(Cells(k, 5)) & "/e_""" & ",nominalformatDate))}</case>" & Chr(10);
            Print #2, "      <default to=""" & Cells(k, 5) & """ />" & Chr(10);
            Print #2, "    </switch>" & Chr(10);
            Print #2, "  </decision>" & Chr(10);
            Print #2, "  " & Chr(10);
            Print #2, "  <action name=""" & Cells(k, 5) & """>" & Chr(10);
            Print #2, "    <shell xmlns=""uri:oozie:shell-action:0.2"">" & Chr(10);
            Print #2, "      <job-tracker>${jobtracker_address}</job-tracker>" & Chr(10);
            Print #2, "      <name-node>${namenode_address}</name-node>" & Chr(10);
            Print #2, "      <configuration>" & Chr(10);
            Print #2, "        <property>" & Chr(10);
            Print #2, "          <name>mapred.job.queue.name</name>" & Chr(10);
            Print #2, "          <value>${mapred_job_queue_name}</value>" & Chr(10);
            Print #2, "        </property>" & Chr(10);
            Print #2, "      </configuration>" & Chr(10);
            Print #2, "      <exec>export_" & Cells(k, 5) & ".sh</exec>" & Chr(10);
            Print #2, "      <argument>${nominal_date}</argument>" & Chr(10);
            Print #2, "      <argument>${" & LCase(Cells(k, 7)) & "_db_jdbc}</argument>" & Chr(10);
            Print #2, "      <argument>${" & LCase(Cells(k, 7)) & "_db_username}<</argument>" & Chr(10);
            Print #2, "      <argument>${" & LCase(Cells(k, 7)) & "_db_password}</argument>" & Chr(10);
            Print #2, "      <argument>${mapred_job_queue_name}</argument>" & Chr(10);
            Print #2, "      <file>shell/export_" & Cells(k, 5) & ".sh#export_" & Cells(k, 5) & ".sh</file>" & Chr(10);
            Print #2, "    </shell>" & Chr(10);
            Print #2, "    <ok to=""create_path" & n & """ />" & Chr(10);
            Print #2, "    <error to=""fail"" />" & Chr(10);
            Print #2, "  </action>" & Chr(10);
            Print #2, "  " & Chr(10);
            Print #2, "  <action name=""create_path" & n & """>" & Chr(10);
            Print #2, "    <fs>" & Chr(10);
            Print #2, "      <mkdir path=""" & "${namenode_address}/apps-data/hduser0301/" & Cells(i, 1) & "/" & Cells(i, 1) & "_" & Cells(i, 2) & "_cd/" & UCase(Cells(k, 5)) & "/e_${nominalformatDate}/" & """ />" & Chr(10);
            Print #2, "    </fs>" & Chr(10);
            Print #2, "    <ok to=""joining"" />" & Chr(10);
            Print #2, "    <error to=""fail"" />" & Chr(10);
            Print #2, "  </action>" & Chr(10);
            Print #2, "  " & Chr(10);
            n = n + 1
            Exit Do
        Loop
    Next
    Print #2, "  <join name=""joining"" to=""end"" />" & Chr(10);
    Print #2, "  " & Chr(10);
    Print #2, "  <kill name=""fail"">" & Chr(10);
    Print #2, "    <message>" & Cells(i, 3) & " workflow failed, error message[${wf:errorMessage(wf:lastErrorNode())}]</message>" & Chr(10);
    Print #2, "  </kill>" & Chr(10);
    Print #2, "  " & Chr(10);
    Print #2, "  <end name=""end"" />" & Chr(10);
    Print #2, "  " & Chr(10);
    Print #2, "</workflow-app>" & Chr(10);
    Close #2
    Set objFile = CreateObject("Scripting.FileSystemObject")
    Set stmFile = objFile.OpenTextFile(workflow_name, 1, False)
    strText = stmFile.ReadAll
    stmFile.Close
    Call WriteUtf8(workflow_name, strText)
    '3. ##################################
  Next
    Sheets("home").Select
    MsgBox "测试验收-推数作业已经生成！"
End Sub
'##################################################
'#    Utf8WithoutBom
'##################################################
Sub update_cfbdm_properties()
'
  Application.ScreenUpdating = False
  Dim path_name As String
  Dim properties_name As String
  Dim MyFile As Object
  Dim objFile, stmFile As Object
  Dim strText As String
  Sheets("home").Select
  root_path = Cells(4, 7) & "\"
  version_path = root_path & Cells(3, 7) & "\"
  Set MyFile = CreateObject("Scripting.FileSystemObject")
  Sheets("coordinator").Select
  arr = Range("A1").CurrentRegion
  For i = 2 To UBound(arr)
    Sheets("coordinator").Select
    level_path = Cells(i, 1) & "\"
    coord_path = Cells(i, 3) & "\"
    queue_name = "queue_0301_01"
    level_name = Cells(i, 1)
    coord_name = Cells(i, 3)
    job_start = Cells(i, 10)
    If Dir(version_path & level_path, vbDirectory) = "" Then
        MkDir version_path & level_path
    End If
    '1. ###### 判断cfbdm.properties是否存在 ######
    path_name = version_path & level_path & coord_path
    properties_name = path_name & "cfbdm.properties"
    If Dir(path_name, vbDirectory) <> "" Then
      If MyFile.FileExists(properties_name) = True Then
        Kill (properties_name)
      End If
    Else
      MkDir path_name
    End If
    '1. ##############################################
    Sheets("coor_properties").Select
    '4. ###### 生成cfbdm.properties文件 ######
    arr1 = Range("A1").CurrentRegion
    Open properties_name For Append As #1
    For p = 1 To UBound(arr1)
        If Cells(p, 1) <> "########" Then
            Print #1, Cells(p, 1) & Replace(Replace(Replace(Replace(Replace(Cells(p, 2), "<level_name>", level_name), "<coord_name>", coord_name), "<job_start>", job_start), "<job_end>", "2999-12-31T12:00+0800"), "<queue_name>", queue_name) & Chr(10);
        Else
            Print #1, "  " & Chr(10);
            Print #1, "  " & Chr(10);
        End If
    Next
    Close #1
    Set objFile = CreateObject("Scripting.FileSystemObject")
    Set stmFile = objFile.OpenTextFile(properties_name, 1, False)
    strText = stmFile.ReadAll
    stmFile.Close
    Call WriteUtf8(properties_name, strText)
    '4. ######################################
  Next
    Sheets("home").Select
    MsgBox "投产上线-定时作业已经生成！"
End Sub
