Class ZPMModules.Log Extends %CSP.Page [ ProcedureBlock ]
{
Parameter TableHeader As STRING = "DB Dir,GlobalName,Details";

Parameter Title As STRING = "Integrity Log";

ClassMethod OnPage() As %Status
{
	write "<head>"
	write "<link rel=""stylesheet"" href=""https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css"">"
	write "<link rel=""stylesheet"" href=""https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap5.min.css"">"
	write "<script src=""https://code.jquery.com/jquery-3.7.0.js""></script>"
	write "<script src=""https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js""></script>"
	write "<script src=""https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap5.min.js""></script>"
	write "</head>"
	write "<title>"_..#Title_"</title>"
	write "<body>"
	write "<div>"
	write "<img class=""portalLogo"" src=""portal/InterSystems IRIS.png"">"
	write "</div>"
	write " <table id=""example"" class=""table table-striped"" style=""width:100%;padding: 0.1rem 0.1rem;font-size:12px;"">"
	write " <thead class='table-header'>"
	write "<tr>"
	set header = $listfromstring(..#TableHeader)
	set ptr=0
	while $listnext(header,ptr,head) {
		write "<th style='background-color:#333695;color:white;'>"_head_"</th>"
	} 
	write "</tr>"
	write "<tbody>"
	set dir=""
	for {
		set dir=$order(%gbl(dir)) quit:dir=""
		set gbl=""		
		for i=1:1{
		set gbl=$order(%gbl(dir,gbl),1,details) q:gbl=""
			set details = $replace(details,$C(13,10),"<br>")
			set alert=$select(+$piece(details,"<br>")>0:1,1:0)			
			write "<tr>"
			write "<td>"_dir_"</td><td>"_gbl_"</td><td>"_details_"</td>"
			write "</tr>"
		}
	}	
	write "</tbody>"
	write "</table>"
	write "</body>"
	;
	&HTML<
		<style>
			tr:hover{
					background-color:#f5f5f5;
					transform:scale(1.01);
				}
		</style>
		<script language="javascript">
		$(document).ready(function(){
	        $('#example').DataTable();
	    })
		</script>
		>
	return $$$OK
}

ClassMethod OnPreHTTP() As %Boolean
{
	Do ..LoadIntegrityData()
	return $$$OK
}

ClassMethod OnPageHEAD() As %Boolean
{
	Do ..HyperEventHead(0,0)
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

}
