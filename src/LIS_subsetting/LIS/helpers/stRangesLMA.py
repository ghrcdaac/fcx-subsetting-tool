def stRangesLMA(fdate):
    """get spatial ranges """
    if(fdate=='2017-05-17'):
        lats,latn=  30., 50.   #25.,  50.
        lonw,lone=-110., -80.
        networks=['OKLMA','WTXLMA']
    elif(fdate=='2017-05-14'):
        lats,latn=  22.,  35.
        lonw,lone= -85., -70.
        networks=['KSCLMA']
    elif(fdate=='2017-05-12'):
        lats,latn=  25.,  40.
        lonw,lone=-100., -80.
        networks=[]
    elif(fdate=='2017-05-08'):
        lats,latn=  30.,  50.
        lonw,lone=-115., -85.
        networks=['COLMA']
    elif(fdate=='2017-05-07'):
        lats,latn=  25.,  40.
        lonw,lone= -90., -70.
        networks=[]
    elif(fdate=='2017-04-22'):
        lats,latn=  25.,  45.
        lonw,lone= -95., -70.
        networks=['NALMA']
    elif(fdate=='2017-04-20'):
        lats,latn=  30.,  50.
        lonw,lone= -95., -70.
        networks=['SOLMA']
    elif(fdate=='2017-04-18'):
        lats,latn=  25.,  45.
        lonw,lone= -95., -70.
        networks=['NALMA']
    else:
        lats,latn=  25.,  45.
        lonw,lone= -100., -70.
        networks=[]
    
    Range=(lonw, lats, lone, latn)  #(lats,latn,lonw,lone)
    return Range,networks