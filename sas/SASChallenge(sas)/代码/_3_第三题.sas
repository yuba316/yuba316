libname original "E:\sas\sas大赛\数据预处理";
libname Q3 "E:\sas\sas大赛\第三题";

/* ========= 计算各阶段各类内的行业预期收益率 =========*/

%let sg = sg1;
%let stage = 1;

data Q3.&sg;
    set original.data_0;
	if period = &stage;
	keep A obs _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r;
run;

proc means data = Q3.&sg noprint;
    var _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r;
	output out = Q3.&sg._mean;
run;

data Q3.&sg._mean;
    set Q3.&sg._mean;
	if _STAT_ = "MEAN";
	drop _TYPE_ _FREQ_;
run;

/* proc export data = Q3.&sg._mean outfile = "E:\sas\sas大赛\第三题\协方差矩阵\&sg._mean.xlsx" dbms=xlsx;
run;*/

/* ========= 计算各阶段各产业链间的行业协方差矩阵 =========*/

proc corr data = Q3.&sg cov outp = Q3.&sg._cov nocorr;
    var _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r;
run;

data Q3.&sg._cov;
    set Q3.&sg._cov;
	if _NAME_ = '' then delete;
	drop _TYPE_;
run;

/*proc export data = Q3.&sg._cov outfile = "E:\sas\sas大赛\第三题\协方差矩阵\&sg._cov.xlsx" dbms=xlsx;
run;*/

/* ========= 构建最大化夏普比率投资组合 =========*/

ods rtf file="E:\sas\sas大赛\第三题\马科维茨\sg1_markovic.doc";
proc nlp outest = sg1_markovic;
    parms _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r;
	cov = 5*5*0.000187561*_801040_SWI_r*_801040_SWI_r+5*4*0.000129545*_801040_SWI_r*_801890_SWI_r+5*3*0.000115394*_801040_SWI_r*_801020_SWI_r+5*9*0.000125995*_801040_SWI_r*_801160_SWI_r+5*6*0.000129635*_801040_SWI_r*_801210_SWI_r+4*5*0.000129545*_801890_SWI_r*_801040_SWI_r+4*4*0.00016512*_801890_SWI_r*_801890_SWI_r+4*3*0.000127893*_801890_SWI_r*_801020_SWI_r+4*9*0.000154814*_801890_SWI_r*_801160_SWI_r+4*6*0.000166953*_801890_SWI_r*_801210_SWI_r+3*5*0.000115394*_801020_SWI_r*_801040_SWI_r+3*4*0.000127893*_801020_SWI_r*_801890_SWI_r+3*3*0.000221391*_801020_SWI_r*_801020_SWI_r+3*9*0.000140303*_801020_SWI_r*_801160_SWI_r+3*6*0.000145065*_801020_SWI_r*_801210_SWI_r+
9*5*0.000125995*_801160_SWI_r*_801040_SWI_r+9*4*0.000154814*_801160_SWI_r*_801890_SWI_r+9*3*0.000140303*_801160_SWI_r*_801020_SWI_r+9*9*0.000181228*_801160_SWI_r*_801160_SWI_r+9*6*0.000174098*_801160_SWI_r*_801210_SWI_r+6*5*0.000129635*_801210_SWI_r*_801040_SWI_r+6*4*0.000166953*_801210_SWI_r*_801890_SWI_r+6*3*0.000145065*_801210_SWI_r*_801020_SWI_r+6*9*0.000174098*_801210_SWI_r*_801160_SWI_r+6*6*0.00021546*_801210_SWI_r*_801210_SWI_r;
    mean = 5*_801040_SWI_r*0.00148611+4*_801890_SWI_r*0.00165871+3*_801020_SWI_r*0.00204765+9*_801160_SWI_r*0.00116872+6*_801210_SWI_r*0.00163118;
	shape = mean/sqrt(cov);
	max shape;
	bounds 0 <= _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r <= 1;
	lincon  5*_801040_SWI_r+4*_801890_SWI_r+3*_801020_SWI_r+9*_801160_SWI_r+6*_801210_SWI_r=1;
run;
ods rtf close;

ods rtf file="E:\sas\sas大赛\第三题\马科维茨\sg2_markovic.doc";
proc nlp outest = sg2_markovic;
    parms _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r;
	cov = 5*5*0.000221176*_801040_SWI_r*_801040_SWI_r+5*4*0.000175061*_801040_SWI_r*_801890_SWI_r+5*3*0.000200158*_801040_SWI_r*_801020_SWI_r+5*9*0.000186508*_801040_SWI_r*_801160_SWI_r+5*6*0.000176313*_801040_SWI_r*_801210_SWI_r+4*5*0.000175061*_801890_SWI_r*_801040_SWI_r+4*4*0.000198502*_801890_SWI_r*_801890_SWI_r+4*3*0.00019358*_801890_SWI_r*_801020_SWI_r+4*9*0.000184201*_801890_SWI_r*_801160_SWI_r+4*6*0.000199071*_801890_SWI_r*_801210_SWI_r+3*5*0.000200158*_801020_SWI_r*_801040_SWI_r+3*4*0.00019358*_801020_SWI_r*_801890_SWI_r+3*3*0.000282776*_801020_SWI_r*_801020_SWI_r+3*9*0.0002101*_801020_SWI_r*_801160_SWI_r+3*6*0.000200221*_801020_SWI_r*_801210_SWI_r+
9*5*0.000186508*_801160_SWI_r*_801040_SWI_r+9*4*0.000184201*_801160_SWI_r*_801890_SWI_r+9*3*0.0002101*_801160_SWI_r*_801020_SWI_r+9*9*0.000209393*_801160_SWI_r*_801160_SWI_r+9*6*0.000192381*_801160_SWI_r*_801210_SWI_r+6*5*0.000176313*_801210_SWI_r*_801040_SWI_r+6*4*0.000199071*_801210_SWI_r*_801890_SWI_r+6*3*0.000200221*_801210_SWI_r*_801020_SWI_r+6*9*0.000192381*_801210_SWI_r*_801160_SWI_r+6*6*0.000245566*_801210_SWI_r*_801210_SWI_r;
    mean = 5*_801040_SWI_r*-0.00038224+4*_801890_SWI_r*-0.0010961+3*_801020_SWI_r*-0.00060573+9*_801160_SWI_r*-0.00066873+6*_801210_SWI_r*-0.0009951;
	shape = mean/sqrt(cov);
	max shape;
	bounds 0 <= _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r <= 1;
	lincon  5*_801040_SWI_r+4*_801890_SWI_r+3*_801020_SWI_r+9*_801160_SWI_r+6*_801210_SWI_r=1;
run;
ods rtf close;

ods rtf file="E:\sas\sas大赛\第三题\马科维茨\sg3_markovic.doc";
proc nlp outest = sg3_markovic;
    parms _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r;
	cov = 5*5*0.000472393*_801040_SWI_r*_801040_SWI_r+5*4*0.000336398*_801040_SWI_r*_801890_SWI_r+5*3*0.000386585*_801040_SWI_r*_801020_SWI_r+5*9*0.000329235*_801040_SWI_r*_801160_SWI_r+5*6*0.000314633*_801040_SWI_r*_801210_SWI_r+4*5*0.000336398*_801890_SWI_r*_801040_SWI_r+4*4*0.000442485*_801890_SWI_r*_801890_SWI_r+4*3*0.000396795*_801890_SWI_r*_801020_SWI_r+4*9*0.000338371*_801890_SWI_r*_801160_SWI_r+4*6*0.000349506*_801890_SWI_r*_801210_SWI_r+3*5*0.000386585*_801020_SWI_r*_801040_SWI_r+3*4*0.000396795*_801020_SWI_r*_801890_SWI_r+3*3*0.000599984*_801020_SWI_r*_801020_SWI_r+3*9*0.00036635*_801020_SWI_r*_801160_SWI_r+3*6*0.000350544*_801020_SWI_r*_801210_SWI_r+
9*5*0.000329235*_801160_SWI_r*_801040_SWI_r+9*4*0.000338371*_801160_SWI_r*_801890_SWI_r+9*3*0.00036635*_801160_SWI_r*_801020_SWI_r+9*9*0.000376284*_801160_SWI_r*_801160_SWI_r+9*6*0.000307368*_801160_SWI_r*_801210_SWI_r+6*5*0.000314633*_801210_SWI_r*_801040_SWI_r+6*4*0.000349506*_801210_SWI_r*_801890_SWI_r+6*3*0.000350544*_801210_SWI_r*_801020_SWI_r+6*9*0.000307368*_801210_SWI_r*_801160_SWI_r+6*6*0.000486365*_801210_SWI_r*_801210_SWI_r;
    mean = 5*_801040_SWI_r*0.00324933+4*_801890_SWI_r*0.00369387+3*_801020_SWI_r*0.00392846+9*_801160_SWI_r*0.00264698+6*_801210_SWI_r*0.00327875;
	shape = mean/sqrt(cov);
	max shape;
	bounds 0 <= _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r <= 1;
	lincon  5*_801040_SWI_r+4*_801890_SWI_r+3*_801020_SWI_r+9*_801160_SWI_r+6*_801210_SWI_r=1;
run;
ods rtf close;

ods rtf file="E:\sas\sas大赛\第三题\马科维茨\sg4_markovic.doc";
proc nlp outest = sg4_markovic;
    parms _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r;
	cov = 5*5*0.00112356*_801040_SWI_r*_801040_SWI_r+5*4*0.000873459*_801040_SWI_r*_801890_SWI_r+5*3*0.000746782*_801040_SWI_r*_801020_SWI_r+5*9*0.000865487*_801040_SWI_r*_801160_SWI_r+5*6*0.000854324*_801040_SWI_r*_801210_SWI_r+4*5*0.000873459*_801890_SWI_r*_801040_SWI_r+4*4*0.000870929*_801890_SWI_r*_801890_SWI_r+4*3*0.000688947*_801890_SWI_r*_801020_SWI_r+4*9*0.000811656*_801890_SWI_r*_801160_SWI_r+4*6*0.000860481*_801890_SWI_r*_801210_SWI_r+3*5*0.000746782*_801020_SWI_r*_801040_SWI_r+3*4*0.000688947*_801020_SWI_r*_801890_SWI_r+3*3*0.000958255*_801020_SWI_r*_801020_SWI_r+3*9*0.000683995*_801020_SWI_r*_801160_SWI_r+3*6*0.000654734*_801020_SWI_r*_801210_SWI_r+
9*5*0.000865487*_801160_SWI_r*_801040_SWI_r+9*4*0.000811656*_801160_SWI_r*_801890_SWI_r+9*3*0.000683995*_801160_SWI_r*_801020_SWI_r+9*9*0.000892056*_801160_SWI_r*_801160_SWI_r+9*6*0.000820472*_801160_SWI_r*_801210_SWI_r+6*5*0.000854324*_801210_SWI_r*_801040_SWI_r+6*4*0.000860481*_801210_SWI_r*_801890_SWI_r+6*3*0.000654734*_801210_SWI_r*_801020_SWI_r+6*9*0.000820472*_801210_SWI_r*_801160_SWI_r+6*6*0.00124256*_801210_SWI_r*_801210_SWI_r;
    mean = 5*_801040_SWI_r*-0.0040196+4*_801890_SWI_r*-0.0033866+3*_801020_SWI_r*-0.0045237+9*_801160_SWI_r*-0.0031488+6*_801210_SWI_r*-0.0043575;
	shape = mean/sqrt(cov);
	max shape;
	bounds 0 <= _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r <= 1;
	lincon  5*_801040_SWI_r+4*_801890_SWI_r+3*_801020_SWI_r+9*_801160_SWI_r+6*_801210_SWI_r=1;
run;
ods rtf close;

ods rtf file="E:\sas\sas大赛\第三题\马科维茨\sg5_markovic.doc";
proc nlp outest = sg5_markovic;
    parms _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r;
	cov = 5*5*0.000677641*_801040_SWI_r*_801040_SWI_r+5*4*0.000566476*_801040_SWI_r*_801890_SWI_r+5*3*0.000649349*_801040_SWI_r*_801020_SWI_r+5*9*0.000386519*_801040_SWI_r*_801160_SWI_r+5*6*0.000548665*_801040_SWI_r*_801210_SWI_r+4*5*0.000566476*_801890_SWI_r*_801040_SWI_r+4*4*0.000762215*_801890_SWI_r*_801890_SWI_r+4*3*0.000713005*_801890_SWI_r*_801020_SWI_r+4*9*0.00045083*_801890_SWI_r*_801160_SWI_r+4*6*0.000699142*_801890_SWI_r*_801210_SWI_r+3*5*0.000649349*_801020_SWI_r*_801040_SWI_r+3*4*0.000713005*_801020_SWI_r*_801890_SWI_r+3*3*0.0010257*_801020_SWI_r*_801020_SWI_r+3*9*0.000463245*_801020_SWI_r*_801160_SWI_r+3*6*0.000694904*_801020_SWI_r*_801210_SWI_r+
9*5*0.000386519*_801160_SWI_r*_801040_SWI_r+9*4*0.00045083*_801160_SWI_r*_801890_SWI_r+9*3*0.000463245*_801160_SWI_r*_801020_SWI_r+9*9*0.000340422*_801160_SWI_r*_801160_SWI_r+9*6*0.000458076*_801160_SWI_r*_801210_SWI_r+6*5*0.000548665*_801210_SWI_r*_801040_SWI_r+6*4*0.000699142*_801210_SWI_r*_801890_SWI_r+6*3*0.000694904*_801210_SWI_r*_801020_SWI_r+6*9*0.000458076*_801210_SWI_r*_801160_SWI_r+6*6*0.000875894*_801210_SWI_r*_801210_SWI_r;
    mean = 5*_801040_SWI_r*0.000970646+4*_801890_SWI_r*0.0023251+3*_801020_SWI_r*0.00248369+9*_801160_SWI_r*0.001398+6*_801210_SWI_r*0.00253398;
	shape = mean/sqrt(cov);
	max shape;
	bounds 0 <= _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r <= 1;
	lincon  5*_801040_SWI_r+4*_801890_SWI_r+3*_801020_SWI_r+9*_801160_SWI_r+6*_801210_SWI_r=1;
run;
ods rtf close;

ods rtf file="E:\sas\sas大赛\第三题\马科维茨\sg6_markovic.doc";
proc nlp outest = sg6_markovic;
    parms _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r;
	cov = 5*5*0.000271263*_801040_SWI_r*_801040_SWI_r+5*4*0.000222307*_801040_SWI_r*_801890_SWI_r+5*3*0.000258524*_801040_SWI_r*_801020_SWI_r+5*9*0.000177975*_801040_SWI_r*_801160_SWI_r+5*6*0.000182477*_801040_SWI_r*_801210_SWI_r+4*5*0.000222307*_801890_SWI_r*_801040_SWI_r+4*4*0.000296217*_801890_SWI_r*_801890_SWI_r+4*3*0.000276002*_801890_SWI_r*_801020_SWI_r+4*9*0.000211873*_801890_SWI_r*_801160_SWI_r+4*6*0.000238648*_801890_SWI_r*_801210_SWI_r+3*5*0.000258524*_801020_SWI_r*_801040_SWI_r+3*4*0.000276002*_801020_SWI_r*_801890_SWI_r+3*3*0.000407563*_801020_SWI_r*_801020_SWI_r+3*9*0.000213435*_801020_SWI_r*_801160_SWI_r+3*6*0.000221197*_801020_SWI_r*_801210_SWI_r+
9*5*0.000177975*_801160_SWI_r*_801040_SWI_r+9*4*0.000211873*_801160_SWI_r*_801890_SWI_r+9*3*0.000213435*_801160_SWI_r*_801020_SWI_r+9*9*0.000194741*_801160_SWI_r*_801160_SWI_r+9*6*0.000187573*_801160_SWI_r*_801210_SWI_r+6*5*0.000182477*_801210_SWI_r*_801040_SWI_r+6*4*0.000238648*_801210_SWI_r*_801890_SWI_r+6*3*0.000221197*_801210_SWI_r*_801020_SWI_r+6*9*0.000187573*_801210_SWI_r*_801160_SWI_r+6*6*0.000277876*_801210_SWI_r*_801210_SWI_r;
    mean = 5*_801040_SWI_r*-0.00064052+4*_801890_SWI_r*0.000052734+3*_801020_SWI_r*-0.00059103+9*_801160_SWI_r*-0.00013541+6*_801210_SWI_r*0.000273421;
	shape = mean/sqrt(cov);
	max shape;
	bounds 0 <= _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r <= 1;
	lincon  5*_801040_SWI_r+4*_801890_SWI_r+3*_801020_SWI_r+9*_801160_SWI_r+6*_801210_SWI_r=1;
run;
ods rtf close;

ods rtf file="E:\sas\sas大赛\第三题\马科维茨\sg7_markovic.doc";
proc nlp outest = sg7_markovic;
    parms _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r;
	cov = 5*5*0.000543038*_801040_SWI_r*_801040_SWI_r+5*4*0.000304489*_801040_SWI_r*_801890_SWI_r+5*3*0.000414201*_801040_SWI_r*_801020_SWI_r+5*9*0.000377703*_801040_SWI_r*_801160_SWI_r+5*6*0.000237238*_801040_SWI_r*_801210_SWI_r+4*5*0.000304489*_801890_SWI_r*_801040_SWI_r+4*4*0.000353835*_801890_SWI_r*_801890_SWI_r+4*3*0.000303449*_801890_SWI_r*_801020_SWI_r+4*9*0.000291862*_801890_SWI_r*_801160_SWI_r+4*6*0.000271402*_801890_SWI_r*_801210_SWI_r+3*5*0.000414201*_801020_SWI_r*_801040_SWI_r+3*4*0.000303449*_801020_SWI_r*_801890_SWI_r+3*3*0.00046648*_801020_SWI_r*_801020_SWI_r+3*9*0.00035542*_801020_SWI_r*_801160_SWI_r+3*6*0.000232912*_801020_SWI_r*_801210_SWI_r+
9*5*0.000377703*_801160_SWI_r*_801040_SWI_r+9*4*0.000291862*_801160_SWI_r*_801890_SWI_r+9*3*0.00035542*_801160_SWI_r*_801020_SWI_r+9*9*0.000379298*_801160_SWI_r*_801160_SWI_r+9*6*0.000238448*_801160_SWI_r*_801210_SWI_r+6*5*0.000237238*_801210_SWI_r*_801040_SWI_r+6*4*0.000271402*_801210_SWI_r*_801890_SWI_r+6*3*0.000232912*_801210_SWI_r*_801020_SWI_r+6*9*0.000238448*_801210_SWI_r*_801160_SWI_r+6*6*0.000284747*_801210_SWI_r*_801210_SWI_r;
    mean = 5*_801040_SWI_r*0.0044921+4*_801890_SWI_r*0.00358351+3*_801020_SWI_r*0.00278931+9*_801160_SWI_r*0.00377316+6*_801210_SWI_r*0.00319378;
	shape = mean/sqrt(cov);
	max shape;
	bounds 0 <= _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r <= 1;
	lincon  5*_801040_SWI_r+4*_801890_SWI_r+3*_801020_SWI_r+9*_801160_SWI_r+6*_801210_SWI_r=1;
run;
ods rtf close;

ods rtf file="E:\sas\sas大赛\第三题\马科维茨\sg8_markovic.doc";
proc nlp outest = sg8_markovic;
    parms _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r;
	cov = 5*5*0.000871125*_801040_SWI_r*_801040_SWI_r+5*4*0.000913522*_801040_SWI_r*_801890_SWI_r+5*3*0.000895017*_801040_SWI_r*_801020_SWI_r+5*9*0.000859077*_801040_SWI_r*_801160_SWI_r+5*6*0.00081809*_801040_SWI_r*_801210_SWI_r+4*5*0.000913522*_801890_SWI_r*_801040_SWI_r+4*4*0.00113109*_801890_SWI_r*_801890_SWI_r+4*3*0.00100189*_801890_SWI_r*_801020_SWI_r+4*9*0.00100488*_801890_SWI_r*_801160_SWI_r+4*6*0.00102218*_801890_SWI_r*_801210_SWI_r+3*5*0.000895017*_801020_SWI_r*_801040_SWI_r+3*4*0.00100189*_801020_SWI_r*_801890_SWI_r+3*3*0.0010147*_801020_SWI_r*_801020_SWI_r+3*9*0.000945299*_801020_SWI_r*_801160_SWI_r+3*6*0.000912294*_801020_SWI_r*_801210_SWI_r+
9*5*0.000859077*_801160_SWI_r*_801040_SWI_r+9*4*0.00100488*_801160_SWI_r*_801890_SWI_r+9*3*0.000945299*_801160_SWI_r*_801020_SWI_r+9*9*0.000963627*_801160_SWI_r*_801160_SWI_r+9*6*0.000926331*_801160_SWI_r*_801210_SWI_r+6*5*0.00081809*_801210_SWI_r*_801040_SWI_r+6*4*0.00102218*_801210_SWI_r*_801890_SWI_r+6*3*0.000912294*_801210_SWI_r*_801020_SWI_r+6*9*0.000926331*_801210_SWI_r*_801160_SWI_r+6*6*0.00107335*_801210_SWI_r*_801210_SWI_r;
    mean = 5*_801040_SWI_r*-0.0035965+4*_801890_SWI_r*-0.0011358+3*_801020_SWI_r*-0.0028239+9*_801160_SWI_r*-0.0019097+6*_801210_SWI_r*0.000111218;
	shape = mean/sqrt(cov);
	max shape;
	bounds 0 <= _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r <= 1;
	lincon  5*_801040_SWI_r+4*_801890_SWI_r+3*_801020_SWI_r+9*_801160_SWI_r+6*_801210_SWI_r=1;
run;
ods rtf close;

ods rtf file="E:\sas\sas大赛\第三题\马科维茨\sg9_markovic.doc";
proc nlp outest = sg9_markovic;
    parms _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r;
	cov = 5*5*0.000332652*_801040_SWI_r*_801040_SWI_r+5*4*0.000214868*_801040_SWI_r*_801890_SWI_r+5*3*0.000255764*_801040_SWI_r*_801020_SWI_r+5*9*0.000176719*_801040_SWI_r*_801160_SWI_r+5*6*0.000163145*_801040_SWI_r*_801210_SWI_r+4*5*0.000214868*_801890_SWI_r*_801040_SWI_r+4*4*0.000252477*_801890_SWI_r*_801890_SWI_r+4*3*0.000199698*_801890_SWI_r*_801020_SWI_r+4*9*0.00019296*_801890_SWI_r*_801160_SWI_r+4*6*0.000196135*_801890_SWI_r*_801210_SWI_r+3*5*0.000255764*_801020_SWI_r*_801040_SWI_r+3*4*0.000199698*_801020_SWI_r*_801890_SWI_r+3*3*0.000253465*_801020_SWI_r*_801020_SWI_r+3*9*0.000163936*_801020_SWI_r*_801160_SWI_r+3*6*0.000154318*_801020_SWI_r*_801210_SWI_r+
9*5*0.000176719*_801160_SWI_r*_801040_SWI_r+9*4*0.00019296*_801160_SWI_r*_801890_SWI_r+9*3*0.000163936*_801160_SWI_r*_801020_SWI_r+9*9*0.000166377*_801160_SWI_r*_801160_SWI_r+9*6*0.000152793*_801160_SWI_r*_801210_SWI_r+6*5*0.000163145*_801210_SWI_r*_801040_SWI_r+6*4*0.000196135*_801210_SWI_r*_801890_SWI_r+6*3*0.000154318*_801210_SWI_r*_801020_SWI_r+6*9*0.000152793*_801210_SWI_r*_801160_SWI_r+6*6*0.000192808*_801210_SWI_r*_801210_SWI_r;
    mean = 5*_801040_SWI_r*0.000195388+4*_801890_SWI_r*-0.00059804+3*_801020_SWI_r*-0.00012162+9*_801160_SWI_r*-0.00054867+6*_801210_SWI_r*-0.00057528;
	shape = mean/sqrt(cov);
	max shape;
	bounds 0 <= _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r <= 1;
	lincon  5*_801040_SWI_r+4*_801890_SWI_r+3*_801020_SWI_r+9*_801160_SWI_r+6*_801210_SWI_r=1;
run;
ods rtf close;

ods rtf file="E:\sas\sas大赛\第三题\马科维茨\sg10_markovic.doc";
proc nlp outest = sg10_markovic;
    parms _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r;
	cov = 5*5*0.000260121*_801040_SWI_r*_801040_SWI_r+5*4*0.000183405*_801040_SWI_r*_801890_SWI_r+5*3*0.000212921*_801040_SWI_r*_801020_SWI_r+5*9*0.000144955*_801040_SWI_r*_801160_SWI_r+5*6*0.00015241*_801040_SWI_r*_801210_SWI_r+4*5*0.000183405*_801890_SWI_r*_801040_SWI_r+4*4*0.000236737*_801890_SWI_r*_801890_SWI_r+4*3*0.000192106*_801890_SWI_r*_801020_SWI_r+4*9*0.000177945*_801890_SWI_r*_801160_SWI_r+4*6*0.000183979*_801890_SWI_r*_801210_SWI_r+3*5*0.000212921*_801020_SWI_r*_801040_SWI_r+3*4*0.000192106*_801020_SWI_r*_801890_SWI_r+3*3*0.00023821*_801020_SWI_r*_801020_SWI_r+3*9*0.000153397*_801020_SWI_r*_801160_SWI_r+3*6*0.000158683*_801020_SWI_r*_801210_SWI_r+
9*5*0.000144955*_801160_SWI_r*_801040_SWI_r+9*4*0.000177945*_801160_SWI_r*_801890_SWI_r+9*3*0.000153397*_801160_SWI_r*_801020_SWI_r+9*9*0.000152075*_801160_SWI_r*_801160_SWI_r+9*6*0.000144599*_801160_SWI_r*_801210_SWI_r+6*5*0.00015241*_801210_SWI_r*_801040_SWI_r+6*4*0.000183979*_801210_SWI_r*_801890_SWI_r+6*3*0.000158683*_801210_SWI_r*_801020_SWI_r+6*9*0.000144599*_801210_SWI_r*_801160_SWI_r+6*6*0.000292384*_801210_SWI_r*_801210_SWI_r;
    mean = 5*_801040_SWI_r*-0.00093172+4*_801890_SWI_r*-0.00056075+3*_801020_SWI_r*-0.00072673+9*_801160_SWI_r*-0.00066866+6*_801210_SWI_r*0.000277223;
	shape = mean/sqrt(cov);
	max shape;
	bounds 0 <= _801040_SWI_r _801890_SWI_r _801020_SWI_r _801160_SWI_r _801210_SWI_r <= 1;
	lincon  5*_801040_SWI_r+4*_801890_SWI_r+3*_801020_SWI_r+9*_801160_SWI_r+6*_801210_SWI_r=1;
run;
ods rtf close;
