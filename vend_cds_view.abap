@AbapCatalog.sqlViewName: 'ZVEN_SQL1'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS View'
define view Zcds_views 
    as select from lfa1 inner join lfb1
        on lfa1.lifnr = lfb1.lifnr
//        left outer join lfbk
//        on lfbk.lifnr = lfbk.lifnr
        left outer join adrc
        on lfa1.adrnr = adrc.addrnumber
        left outer join j_1imovend
        on lfa1.lifnr = j_1imovend.lifnr
        left outer join adr6
        on adrc.addrnumber = adr6.addrnumber
//        left outer join bnka
//        on lfbk.bankl = bnka.bankl 
{
    key  lfa1.lifnr as vendor,
         lfa1.name1,
         lfa1.ort02,
         lfa1.ort01,
         lfa1.pstlz,
         lfa1.erdat,
         lfa1.ktokk,
         lfa1.sperr,
         lfa1.telf1,
         lfa1.telf2,
         lfa1.telfx,
         lfa1.sperq,
         lfa1.stcd3,
         lfa1.stenr,
         lfb1.akont,
         lfb1.zahls,
         lfb1.zterm,
         adrc.str_suppl1,
         adrc.str_suppl2,
         adrc.country,
         adrc.region,
//         lfbk.bankl,
//         lfbk.bankn,
//         lfbk.koinh,
         j_1imovend.j_1ipanno,
         adr6.smtp_addr
}
