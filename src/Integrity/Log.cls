Class Integrity.Log Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod OnPage() As %Status
{
	Do ..LoadSetup()
	Write "<script src=""https://ajax.googleapis.com/ajax/libs/jquery/3.6.4/jquery.min.js""></script>"
	if '$data(%gbl) write "<h1>Integrity Log not found</h1>" return $$$OK
	write "<div>"
	write "<img class=""portalLogo"" src=""portal/InterSystems IRIS.png"">"
	write "<input id=""myInput"" class=""myInput"" type=""text"" placeholder=""Search..."">"
	write "</div>"
	write "<table class=""content-table"">"
	write " <thead>"
	write "<tr>"
	write "<th>DB Dir</th>"
	write "<th>GlobalName</th>"
	write "<th>Details</th>"
	write "</tr>"
	write "</thead>"
	write "<tbody id=""myTable"">"
	set dir=""
	for {
		set dir=$O(%gbl(dir)) quit:dir=""
		set gbl=""
		for i=1:1{
		set gbl=$O(%gbl(dir,gbl),1,details) q:gbl=""
			set details = $replace(details,$C(13,10),"<br>")
			set alert=$S(+$piece(details,"<br>")>0:1,1:0)
			write "<tr class=""row "_$select(alert:" row-danger",1:"")_"""><td>"_dir_"</td><td>"_gbl_"</td><td>"_details_"</td>"
		}
	}			
	write "</tbody>"
	write "</table>"
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
	 		;set %gbl(cdir,$P($P(line,": ",2)," "))=""
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

ClientMethod Write() [ Language = javascript, ServerOnly = 1, WebMethod ]
{
	$(document).ready(function(){
					  $("#myInput").on("keyup", function() {
					    var value = $(this).val().toLowerCase();
					    $("#myTable tr").filter(function() {
					      $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
					    });
					  });
					});
}

ClassMethod OnPageHEAD() As %Boolean
{
	
	Do ..HyperEventHead(0,0)
}

ClassMethod cssStyleSheet()
{
	
	&HTML<
<style type="text/css">

.body1 {
         background: green;
       }
       table {
  font-family: arial, sans-serif;
  border-collapse: collapse;
  width: 100%;
}

td {
  border: 1px solid #dddddd;
  text-align: left;
  padding: 4px;
}

tr:nth-child(even) {
  background-color: #dddddd;
  
}
.row:hover{
	background-color: #dddddd;
}
.row-danger {
	background-color: #ffdddd!important;
}
.myInput {
	padding: 8px 20px;
  	margin: 8px 0;
  	box-sizing: border-box;
  	border-radius: 5px;
}
th{
	background-color: #333695;
    color: white;
    border: 1px solid #dddddd;
 	 text-align: left;
  	padding: 4px;
	position: sticky;
	top:0;
}
.content-table {
	border-radius: 5px 5px 0 0 ;
  	border-collapse:collapse;
  	font-size:0.9em;
  	overflow:hidden;
  	box-shadow: 0 0 5px rgba(0, 0, 0.15);
  	overflow-y: scroll;
}
</style>
	>
}

}
