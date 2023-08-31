Class Samples.Integrity.Log Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod OnPage() As %Status
{
	write "<link rel=""preconnect"" href=""https://fonts.googleapis.com""><link rel=""preconnect"" href=""https://fonts.gstatic.com"" crossorigin><link href=""https://fonts.googleapis.com/css2?family=Roboto+Mono:wght@200;400&family=Source+Code+Pro&display=swap"" rel=""stylesheet"">"
	do ..LoadSetup()
	write "<title>Integrity log</title>"
	write "<script src=""https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js""></script>"
	write "<body>"
	if '$data(%gbl) write "<h2>Integrity Log not found :(</h2>" return $$$OK
	write "<div>"
	write "<img class=""portalLogo"" src=""portal/InterSystems IRIS.png"">"
	write "<input id=""myInput"" class=""myInput"" type=""text"" placeholder=""Search..."">"
	write "</div>"
	write "<table class=""content-table"">"
	write " <thead class='table-header'>"
	write "<tr>"
	write "<th>DB Dir</th>"
	write "<th>GlobalName</th>"
	write "<th>Details</th>"
	write "</tr>"
	write "</thead>"
	write "<tbody id=""myTable"">"
	set dir=""
	for {
		set dir=$order(%gbl(dir)) quit:dir=""
		set gbl=""
		for i=1:1{
		set gbl=$order(%gbl(dir,gbl),1,details) q:gbl=""
			set details = $replace(details,$C(13,10),"<br>")
			set alert=$select(+$piece(details,"<br>")>0:1,1:0)
			write "<tr class=""row "_$select(alert:" row-danger",1:"")_"""><td>"_dir_"</td><td>"_gbl_"</td><td>"_details_"</td>"
		}
	}			
	write "</tbody>"
	write "</table>"
	write "</body>"
	;
	&HTML<
	<script language="javascript">
		$(document).ready(function(){
		  $("#myInput").on("keyup", function() {
		    var value = $(this).val().toLowerCase();
		    $("#myTable tr").filter(function() {
		      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
		    });
		  });
		});
	</script>
	>
	return $$$OK
}

ClassMethod OnPreHTTP() As %Boolean
{
	Do ..LoadIntegrityData()
	return $$$OK
}

ClassMethod LoadIntegrityData() As %Boolean
{
	set file = $SYSTEM.Util.ManagerDirectory()_"integ.txt"
	set stream = ##class(%FileCharacterStream).%New()
 	set stream.Filename = file,data =""
	While 'stream.AtEnd {
 		set line = stream.ReadLine()
 		if line["Directory:" {
	 		Set cdir = $P(line,"Directory: ",2)
 		}
 		if line["Global:" {
	 		set cgbl=$P($P(line,": ",2)," ")
	 		set data=$P($P(line,": ",2)," ",2,*)
 		}
 		else {
	 		set data=data_$C(13,10)_line
	 		if line["Elapsed Time" {
		 		set %gbl(cdir,cgbl)=data
		 		set data=""
	 		}
 		}
	}
	return $$$OK
}

ClassMethod LoadSetup()
{
	Do ..cssStyleSheet()
}

ClassMethod OnPageHEAD() As %Boolean
{
	Do ..HyperEventHead(0,0)
}

ClassMethod cssStyleSheet()
{
	
	&HTML<
<style type="text/css">
 table {
  font-family: arial, sans-serif;
  border-collapse: collapse;
  width: 99%;
}
body {
	font-family: 'Roboto Mono', monospace;
}
td {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 4px;
}

tr:nth-child(even) {
  background-color: rgba(221,221,221,0.18);
}
.row:hover{
	background-color:#f5f5f5;
	transform:scale(1.01);
}
.row-danger {
	background-color: #ffdddd!important;
}
.myInput {
	padding: 8px 20px;
  	margin: 8px 0;
  	box-sizing: border-box;
  	border-radius: 5px;
  	font-family:'Source Code Pro', monospace;
}
th{
	background-color: #333695;
    color: white;
    border: 1px solid #dddddd;
 	text-align: left;
  	padding: 4px;
	position: sticky;
	top:0;
	box-shadow: 5px 5px 5px rgba(0, 0, 0.15);
	padding: 1rem 2rem ;
	text-align:center;
	font-size:0.9rem;
	font-weight:900;
	font-family:'Source Code Pro', monospace;
}
.content-table {
  	border-collapse:collapse;
  	font-size:0.8em;
  	overflow:hidden;
  	box-shadow: 0 0 5px rgba(0, 0, 0.15);
  	overflow-y: scroll;
  	font-family:'Source Code Pro', monospace;
}
thead {
	box-shadow: 0 5px 10px gray;
}
h2 {
	font-family:'Source Code Pro', monospace;
	color:#333695;
}
</style>
	>
}

}
