<?php
class contabilidad_diario_mayor_model{

    public function __construct(){

    }
    
    public function getInfoCuentaBusqueda($intCuentaBancaria = 0){
        
        $arrData = array();
        if( $intCuentaBancaria == 0 ){
            $arrData[0]["texto"] = "Seleccione una opción...";
            $arrData[0]["selected"] = true;
        }
        
        $strQuery ="SELECT  cuenta.cuenta, cuenta.nombre_banco, cuenta.no_cuenta, cuenta.moneda,
                            empresa.empresa, empresa.nombre nombre_empresa
                    FROM    cuenta,
                            empresa
                    WHERE   empresa.activo = 'Y'
                    AND     cuenta.empresa = empresa.empresa";
        $qTMP = db_query($strQuery);
        while( $rTMP = db_fetch_assoc($qTMP) ) {
            $arrData[$rTMP["cuenta"]]["texto"] = $rTMP["nombre_empresa"]." - ".$rTMP["no_cuenta"];
            if( $intCuentaBancaria == $rTMP["cuenta"] ){
                $arrData[$rTMP["cuenta"]]["selected"] = true;
            }
            else{
                $arrData[$rTMP["cuenta"]]["selected"] = false;
            }
        }
        db_free_result($qTMP);
        return $arrData;
        
    }
   
    /* 
    public function getInfoDiarioMayor($intCuenta, $strFechaInicio, $strFechaFin){
        
        $arrInfo = array();
        $intCuenta = !empty($intCuenta) ? $intCuenta : 0;
        
        $strFechaInicio = !empty($strFechaInicio) ? $strFechaInicio : "";
        $arrFechaInicio = explode("/",$strFechaInicio);
        $strFechaInicio = $arrFechaInicio[2]."-".$arrFechaInicio[1]."-".$arrFechaInicio[0];
        
        $strFechaFin = !empty($strFechaFin) ? $strFechaFin : "";
        $arrFechaFin = explode("/",$strFechaFin);
        $strFechaFin = $arrFechaFin[2]."-".$arrFechaFin[1]."-".$arrFechaFin[0];
        
        $strAndFechaInicio = "";
        $strAndFechaFin = "";
        
        if( !empty($strFechaFin) ){
            $strAndFechaInicio = "AND    nota.fecha >= '{$strFechaInicio}'";
            $strAndFechaInicioCheque = "AND    cheque.fecha >= '{$strFechaInicio}'";
        }
        
        if( !empty($strFechaFin) ){
            $strAndFechaFin = "AND    nota.fecha <= '{$strFechaFin}'";
            $strAndFechaFinCheque = "AND    cheque.fecha <= '{$strFechaFin}'";
        }
        
        $sinTotal = 0;
        $strDescripcion = "";
        $sinDebito = 0;
        $sinCredito = 0;
        
        $strQuery = "SELECT nota.nota id, 
                            nota.tipo, 
                            nota.is_deposito, 
                            nota.monto, 
                            nota.fecha, 
                            nota.tipo_cambio 
                            id_tc, 
                            nota.moneda, 
                            nota.nota_anulado anulado,
                            nota.transferencia, 
                            nota.nota correlativo,
                            moneda.simbolo, 
                            moneda.tipo_cambio moneda_tc
                     FROM   nota,
                            moneda
                     WHERE  nota.moneda = moneda.moneda
                     AND    nota.cuenta IN ( {$intCuenta} )
                     {$strAndFechaInicio}
                     {$strAndFechaFin}
                     
                     UNION
                     
                     SELECT cheque.solicitud_cheque id, 
                            'ch' tipo, 
                            'N' is_deposito, 
                            cheque.monto, 
                            cheque.fecha, 
                            cheque.tipo_cambio id_tc, 
                            cheque.moneda, 
                            cheque.cheque_anulado anulado,
                            cheque.transferencia, 
                            cheque.cheque correlativo,
                            moneda.simbolo, 
                            moneda.tipo_cambio moneda_tc
                     FROM   solicitud_cheque cheque,
                            moneda
                     WHERE  cheque.moneda = moneda.moneda
                     AND    cheque.autorizado = 'Y'
                     AND    cheque.cuenta IN ( {$intCuenta} )
                     {$strAndFechaInicioCheque}
                     {$strAndFechaFinCheque}
                     
                     ORDER  BY fecha";
        $qTMP = db_query($strQuery);
        //debugQuery($strQuery);
        while( $rTMP = db_fetch_assoc($qTMP) ){
            
            $arrInfo[$rTMP["id"]]["id"] = $rTMP["id"];
            $arrInfo[$rTMP["id"]]["tipo"] = $rTMP["tipo"];
            $arrInfo[$rTMP["id"]]["is_deposito"] = $rTMP["is_deposito"];
            $arrInfo[$rTMP["id"]]["monto"] = $rTMP["monto"];
            $arrInfo[$rTMP["id"]]["fecha"] = $rTMP["fecha"];
            $arrInfo[$rTMP["id"]]["correlativo"] = $rTMP["correlativo"];
            $arrInfo[$rTMP["id"]]["id_tc"] = $rTMP["id_tc"];
            $arrInfo[$rTMP["id"]]["moneda_tc"] = $rTMP["moneda_tc"];
            $arrInfo[$rTMP["id"]]["simbolo"] = $rTMP["simbolo"];
            $arrInfo[$rTMP["id"]]["moneda"] = $rTMP["moneda"];
            $arrInfo[$rTMP["id"]]["anulado"] = $rTMP["anulado"];
            $arrInfo[$rTMP["id"]]["transferencia"] = $rTMP["transferencia"];
            
            if ( $rTMP["tipo"] == "c" && $rTMP["is_deposito"] == "N" ){
                
                $sinTotal += ( $rTMP["anulado"] == "Y" ) ? 0 : floatval($rTMP["monto"]/$rTMP["id_tc"]);
                $sinCredito = floatval($rTMP["monto"]/$rTMP["id_tc"]);
                $sinDebito = 0;
                $strDescripcion = "Nota de crédito No. ".$rTMP["id"];
            }
            else if ( $rTMP["tipo"] == "c" && $rTMP["is_deposito"] == "Y" ){
                
                $sinTotal += ( $rTMP["anulado"] == "Y" ) ? 0 : floatval($rTMP["monto"]/$rTMP["id_tc"]);
                $sinCredito = floatval($rTMP["monto"]/$rTMP["id_tc"]);
                $sinDebito = 0;
                $strDescripcion = "Depósito No. ".$rTMP["id"];
            }
            else if ( $rTMP["tipo"] == "d" && $rTMP["is_deposito"] == "N" ){
                
                $sinTotal -= ( $rTMP["anulado"] == "Y" ) ? 0 : floatval($rTMP["monto"]/$rTMP["id_tc"]);
                $sinDebito = floatval($rTMP["monto"]/$rTMP["id_tc"]);
                $sinCredito = 0;
                $strDescripcion = "Nota de débito No. ".$rTMP["id"];
            }
            else if( $rTMP["tipo"] == "ch" && $rTMP["is_deposito"] == "N" ){
                
                $sinTotal -= ( $rTMP["anulado"] == "Y" ) ? 0 : floatval($rTMP["monto"]/$rTMP["id_tc"]);
                $sinDebito = floatval($rTMP["monto"]/$rTMP["id_tc"]);
                $sinCredito = 0;
                $strDescripcion = "Cheque No. ".$rTMP["correlativo"];
            }
            
            $arrInfo[$rTMP["id"]]["total"] = $sinTotal;
            $arrInfo[$rTMP["id"]]["descripcion"] = $strDescripcion;
            $arrInfo[$rTMP["id"]]["credito"] = $sinCredito;
            $arrInfo[$rTMP["id"]]["debito"] = $sinDebito;
            
        }
        db_free_result($qTMP);
        
        return $arrInfo;
    }
    */
    public function getCantidadSaltoAnt( $strFechaInicio ){  
        
        $strFechaInicio = !empty($strFechaInicio) ? $strFechaInicio : "";
        $arrFechaInicio = explode("/",$strFechaInicio);
        $strFechaInicio = $arrFechaInicio[2]."-".$arrFechaInicio[1]."-".$arrFechaInicio[0];
        
        $arrInfo = array();
        $strQuery = "SELECT cuenta_contable.cuenta_contable, 
                            SUM(IF(partida_transaccion.tipo = cuenta_contable.tipo,partida_transaccion.monto,(partida_transaccion.monto*-1))) saldo_anterior
                     FROM cuenta_contable, partida_transaccion, partida
                     WHERE cuenta_contable.cuenta_contable = partida_transaccion.cuenta_contable
                     AND partida_transaccion.partida = partida.partida
                     AND partida.fecha < '{$strFechaInicio}'
                     GROUP BY cuenta_contable.cuenta_contable";   
        $qTMP = db_query($strQuery);
        while( $rTMP = db_fetch_assoc($qTMP) ){
            $arrInfo[$rTMP["cuenta_contable"]] = $rTMP["saldo_anterior"];   
        } 
        return $arrInfo;
    }
    
    public function getInfoDiarioMayor($strFechaInicio, $strFechaFin){
        
        $arrSaldos = array();
        $arrSaldos["saldo_inicial"] = $this->getCantidadSaltoAnt($strFechaInicio);
        $arrSaldos["saldo_actual"] = $this->getCantidadSaltoAnt($strFechaFin);  //Obtener primero la fecha fin más 1 dia
        
        
        $arrInfo = array();
        $strFechaInicio = !empty($strFechaInicio) ? $strFechaInicio : "";
        $arrFechaInicio = explode("/",$strFechaInicio);
        $strFechaInicio = $arrFechaInicio[2]."-".$arrFechaInicio[1]."-".$arrFechaInicio[0];
        
        $strFechaFin = !empty($strFechaFin) ? $strFechaFin : "";
        $arrFechaFin = explode("/",$strFechaFin);
        $strFechaFin = $arrFechaFin[2]."-".$arrFechaFin[1]."-".$arrFechaFin[0];
        
        //$sinTotal = 0;
        $strDescripcion = "";
        $sinDebito = 0;
        $sinCredito = 0;
        
        $arrNomenclatura = array();
        $strQuery = "SELECT cuenta_contable_nomenclatura.cuenta_contable,
                            cuenta_contable_nomenclatura.nomenclatura,
                            cuenta_contable_nomenclatura.nombre,
                            cuenta_contable_nomenclatura.tipo,
                            cuenta_contable_nomenclatura.tiene_hijos
                      FROM  cuenta_contable_nomenclatura
                      ORDER BY nomenclatura";
                      
        $qTMP = db_query($strQuery);
        while( $rTMP = db_fetch_assoc($qTMP) ) {
            
            $arrNomenclatura[$rTMP["cuenta_contable"]]["nomenclatura"] = $rTMP["nomenclatura"];
            $arrNomenclatura[$rTMP["cuenta_contable"]]["nombre"] = $rTMP["nombre"];
            $arrNomenclatura[$rTMP["cuenta_contable"]]["tipo"] = $rTMP["tipo"];
            $arrNomenclatura[$rTMP["cuenta_contable"]]["tiene_hijos"] = $rTMP["tiene_hijos"];
            
        }
        db_free_result($qTMP);
        
        return $arrNomenclatura;
            
        $arrTransacciones = array();
        $strQuery = "SELECT partida_transaccion.cuenta_contable,
                            partida.descripcion, partida.fecha, partida.partida,
                            partida_transaccion.transaccion,
                            partida_transaccion.tipo, partida_transaccion.monto
                     FROM   partida_transaccion, partida
                     WHERE  partida.fecha >= '{$strFechaInicio} 00:00:00'
                     AND    partida.fecha <= '{$strFechaFin} 23:59:59'
                     AND    partida_transaccion.partida = partida.partida
                     ORDER  BY partida_transaccion.cuenta_contable, partida.fecha, partida.partida";
                     
        
        $qTMP = db_query($strQuery);
        while( $rTMP = db_fetch_assoc($qTMP) ) {
            $arrTransacciones[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["partida"] = $rTMP["partida"];
            $arrTransacciones[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["fecha"] = $rTMP["fecha"];
            $arrTransacciones[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["descripcion"] = $rTMP["descripcion"];
            $arrTransacciones[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["monto"] = $rTMP["monto"];
            $arrTransacciones[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["tipo"] = $rTMP["tipo"];
        }
        db_free_result($qTMP);
        
        //drawDebug($arrSaldos);
        
        $arrDocumentos = array();
        $strQuery = "SELECT nota.nota, nota.partida, 
                            partida_transaccion.transaccion, 
                            partida_transaccion.cuenta_contable, 
                            nota.transaccion notaTransaccion
                     FROM   nota, partida_transaccion, partida 
                     WHERE  partida.fecha >= '{$strFechaInicio} 00:00:00'
                     AND    partida.fecha <= '{$strFechaFin} 23:59:59'
                     AND    nota.partida = partida.partida
                     AND    partida.partida = partida_transaccion.partida
                     ORDER  BY partida_transaccion.cuenta_contable, partida.partida";
                     
        //debugQuery($strQuery);
                     
        $qTMP = db_query($strQuery);
        while( $rTMP = db_fetch_assoc($qTMP) ) {
            
            $arrDocumentos[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["documento"] = "Nota de algo No. {$rTMP["notaTransaccion"]}";
            
        }
        db_free_result($qTMP);
        
        //drawDebug($arrDocumentos);
        
        //die();
                      
        
        ?>
        
        <!--<table>
            <tr>
                <td>Cuenta</td>
                <td>Fecha</td>
                <td>Documento</td>
                <td>Descripción</td>
                <td>Número</td>
                <td>Saldo Inicial</td>
                <td>Debe</td>
                <td>Haber</td>
                <td>Saldo Actual</td>
            </tr>-->
        
            <?php
            /*
            foreach($arrNomenclatura as $key=>$value) {
                
                $intCuentaContable = $key;
                ?>
                <tr>
                    <td><?php print $value["nomenclatura"] ?></td>
                    <td>&nbsp;</td>
                    <td><?php print $value["nombre"] ?></td>
                    <td>&nbsp;</td>
                    <td><?php print isset($arrSaldos["saldo_inicial"][$intCuentaContable]) ? number_format($arrSaldos["saldo_inicial"][$intCuentaContable],2) : ( $value["tiene_hijos"] == "Y" ? "&nbsp;" : number_format(0,2) ); ?></td>
                    <td>&nbsp;</td>
                    <td>&nbsp;</td>
                    <td><?php print isset($arrSaldos["saldo_actual"][$intCuentaContable]) ? number_format($arrSaldos["saldo_actual"][$intCuentaContable],2) : ( $value["tiene_hijos"] == "Y" ? "&nbsp;" : number_format(0,2) ); ?></td>
                </tr>
                <?php
                
                if( isset($arrTransacciones[$intCuentaContable]) &&  $value["tiene_hijos"] == "N" ) {
                    
                    foreach($arrTransacciones[$intCuentaContable] as $keyInterno=>$valueInterno) {
                        
                        $intPartidaTransaccion = $keyInterno;
                        
                        ?>
                        <tr>
                            <td><?php print $value["nomenclatura"] ?></td>
                            <td><?php print $valueInterno["fecha"]; ?></td>
                            <td><?php print isset($arrDocumentos[$intCuentaContable][$keyInterno]) ? print $arrDocumentos[$intCuentaContable][$keyInterno] : "&nbsp;"  ?></td>
                            <td><?php print $valueInterno["descripcion"] ?></td>
                            <td><?php print $valueInterno["partida"] ?></td>
                            <td>&nbsp;</td>
                            <td><?php print $valueInterno["tipo"] == "D" ? number_format($valueInterno["monto"],2) : "&nbsp;"; ?></td>
                            <td><?php print $valueInterno["tipo"] == "A" ? number_format($valueInterno["monto"],2) : "&nbsp;"; ?></td>
                            <td>&nbsp;</td>
                        </tr>
                        <?php
                        
                    }
                    
                    
                }
                
                
            }
            */
            ?>
            
        <!--</table>-->
        
        <?php
        
        
        die();
        
       // drawDebug($arrNomenclatura); 
        //drawDebug($arrTransacciones);
        
        
        
         
        
      //  die();
        
        
        
        
        /*$strQuery = "SELECT  nom.cuenta_contable id,
                             nom.nomenclatura,
                             nom.nombre AS nombre_cuenta,
                             partida.partida partida_id,
                             partida.nombre nombre_partida,
                             partida.descripcion descripcion_partida,
                             nom.nivel,
                             nom.activo,
                             nom.tiene_hijos,
                             nom.cuenta_padre,
                             partida_transaccion.tipo,
                             partida_transaccion.transaccion,
                             partida_transaccion.partida,
                             partida_transaccion.cuenta_contable,
                             DATE_FORMAT(partida.fecha,'%d/%m/%Y') fecha,
                             IF(partida_transaccion.tipo = 'D', partida_transaccion.monto,0 ) debe_recibe,
                             IF(partida_transaccion.tipo = 'A', partida_transaccion.monto,0 ) haber_entrega,
                             IF(nota.tipo IS NOT NULL,
                                IF(nota.is_deposito = 'Y',CONCAT('DE ','numero'),
                                    IF(nota.tipo='c',
                                    CONCAT('NC ',nota.transaccion),
                                    CONCAT('ND ',nota.transaccion)
                                    )
                                ),
                                IF(cheque.numerocheque IS NOT NULL,
                                    CONCAT('CH ', 
                                    cheque.numerocheque),'')
                             ) tipo_documento,
                             
                             IF(cheque.numerocheque IS NOT NULL OR (nota.tipo='d' AND nota.is_deposito = 'N'),
                                'Egresos',
                                IF( nota.is_deposito = 'Y',
                                'Ingreso',IF(nota.tipo = 'c','Ajustes',''))
                             ) tipo_poliza
                             
                     FROM    cuenta_contable_nomenclatura nom
                             LEFT JOIN partida_transaccion
                                ON partida_transaccion.cuenta_contable = nom.cuenta_contable
                             LEFT JOIN partida
                                ON partida.partida = partida_transaccion.partida
                             LEFT JOIN cuenta
                                  ON cuenta.cuenta_contable = nom.cuenta_contable
                             LEFT JOIN nota
                                ON nota.cuenta = cuenta.cuenta
                                AND nota.partida = partida.partida
                             LEFT JOIN solicitud_cheque
                                ON solicitud_cheque.partida = partida.partida
                                AND solicitud_cheque.cuenta_contable = nom.cuenta_contable
                             LEFT JOIN cheque
                                ON cheque.cheque = solicitud_cheque.solicitud_cheque
                     WHERE 1=1
                   
                     ORDER BY nom.nomenclatura"; */
        $strQuery = "SELECT * FROM (
                        SELECT   nom.cuenta_contable id,
                                 nom.nomenclatura,
                                 nom.nombre AS nombre_cuenta,
                                 partida.partida partida_id,
                                 partida.nombre nombre_partida,
                                 partida.descripcion descripcion_partida,
                                 nom.nivel,
                                 nom.activo,
                                 nom.tiene_hijos,
                                 nom.cuenta_padre,
                                 partida_transaccion.tipo,
                                 partida_transaccion.transaccion,
                                 partida_transaccion.partida,
                                 partida_transaccion.cuenta_contable,
                                 DATE_FORMAT(partida.fecha,'%d/%m/%Y') fecha,
                                 IF(partida_transaccion.tipo = 'D', partida_transaccion.monto,0 ) debe_recibe,
                                 IF(partida_transaccion.tipo = 'A', partida_transaccion.monto,0 ) haber_entrega,
                                 IF(nota.tipo IS NOT NULL,
                                    IF(nota.is_deposito = 'Y',CONCAT('DE ','numero'),
                                        IF(nota.tipo='c',
                                        CONCAT('NC ',nota.transaccion),
                                        CONCAT('ND ',nota.transaccion)
                                        )
                                    ),
                                    IF(cheque.numerocheque IS NOT NULL,
                                        CONCAT('CH ', 
                                        cheque.numerocheque),'')
                                 ) tipo_documento,
                                 
                                 IF(cheque.numerocheque IS NOT NULL OR (nota.tipo='d' AND nota.is_deposito = 'N'),
                                    'Egresos',
                                    IF( nota.is_deposito = 'Y',
                                    'Ingreso',IF(nota.tipo = 'c','Ajustes',''))
                                 ) tipo_poliza
                                 
                         FROM    cuenta_contable_nomenclatura nom
                                 LEFT JOIN partida_transaccion
                                    ON partida_transaccion.cuenta_contable = nom.cuenta_contable
                                 LEFT JOIN partida
                                    ON partida.partida = partida_transaccion.partida
                                 LEFT JOIN cuenta
                                      ON cuenta.cuenta_contable = nom.cuenta_contable
                                 LEFT JOIN nota
                                    ON nota.cuenta = cuenta.cuenta
                                    AND nota.partida = partida.partida
                                 LEFT JOIN solicitud_cheque
                                    ON solicitud_cheque.partida = partida.partida
                                    AND solicitud_cheque.cuenta_contable = nom.cuenta_contable
                                 LEFT JOIN cheque
                                    ON cheque.cheque = solicitud_cheque.solicitud_cheque
                         WHERE partida.partida IS NOT NULL
                         AND     partida.fecha >= '{$strFechaInicio} 00:00:00'
                         AND     partida.fecha <= '{$strFechaFin} 23:59:59'
                         UNION
                         SELECT  nom.cuenta_contable id,
                                 nom.nomenclatura,
                                 nom.nombre AS nombre_cuenta,
                                 partida.partida partida_id,
                                 partida.nombre nombre_partida,
                                 partida.descripcion descripcion_partida,
                                 nom.nivel,
                                 nom.activo,
                                 nom.tiene_hijos,
                                 nom.cuenta_padre,
                                 partida_transaccion.tipo,
                                 partida_transaccion.transaccion,
                                 partida_transaccion.partida,
                                 partida_transaccion.cuenta_contable,
                                 DATE_FORMAT(partida.fecha,'%d/%m/%Y') fecha,
                                 IF(partida_transaccion.tipo = 'D', partida_transaccion.monto,0 ) debe_recibe,
                                 IF(partida_transaccion.tipo = 'A', partida_transaccion.monto,0 ) haber_entrega,
                                 IF(nota.tipo IS NOT NULL,
                                    IF(nota.is_deposito = 'Y',CONCAT('DE ','numero'),
                                        IF(nota.tipo='c',
                                        CONCAT('NC ',nota.transaccion),
                                        CONCAT('ND ',nota.transaccion)
                                        )
                                    ),
                                    IF(cheque.numerocheque IS NOT NULL,
                                        CONCAT('CH ', 
                                        cheque.numerocheque),'')
                                 ) tipo_documento,
                                 
                                 IF(cheque.numerocheque IS NOT NULL OR (nota.tipo='d' AND nota.is_deposito = 'N'),
                                    'Egresos',
                                    IF( nota.is_deposito = 'Y',
                                    'Ingreso',IF(nota.tipo = 'c','Ajustes',''))
                                 ) tipo_poliza
                                 
                         FROM    cuenta_contable_nomenclatura nom
                                 LEFT JOIN partida_transaccion
                                    ON partida_transaccion.cuenta_contable = nom.cuenta_contable
                                 LEFT JOIN partida
                                    ON partida.partida = partida_transaccion.partida
                                 LEFT JOIN cuenta
                                      ON cuenta.cuenta_contable = nom.cuenta_contable
                                 LEFT JOIN nota
                                    ON nota.cuenta = cuenta.cuenta
                                    AND nota.partida = partida.partida
                                 LEFT JOIN solicitud_cheque
                                    ON solicitud_cheque.partida = partida.partida
                                    AND solicitud_cheque.cuenta_contable = nom.cuenta_contable
                                 LEFT JOIN cheque
                                    ON cheque.cheque = solicitud_cheque.solicitud_cheque
                         WHERE partida.partida IS NULL
         ) tmpnomenclatura                 
        ORDER BY tmpnomenclatura.nomenclatura";
        $qTMP = db_query($strQuery);
        debugQuery($strQuery);
        while( $rTMP = db_fetch_assoc($qTMP) ){
        
            if( isset( $arrInfo["cuenta_contable"][$rTMP["id"]]["debe_recibe"]) ) {
                $arrInfo["cuenta_contable"][$rTMP["id"]]["debe_recibe"] += $rTMP["debe_recibe"];
            }
            else{
                $arrInfo["cuenta_contable"][$rTMP["id"]]["debe_recibe"] = $rTMP["debe_recibe"];   
            }
            
            if( isset( $arrInfo["cuenta_contable"][$rTMP["id"]]["haber_entrega"]) ) {
                $arrInfo["cuenta_contable"][$rTMP["id"]]["haber_entrega"] += $rTMP["haber_entrega"];
            }
            else{
                $arrInfo["cuenta_contable"][$rTMP["id"]]["haber_entrega"] = $rTMP["haber_entrega"];   
            }   
            
            $arrInfo["cuenta_contable"][$rTMP["id"]]["id"] = $rTMP["id"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["partida_id"] = $rTMP["partida_id"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["nomenclatura"] = $rTMP["nomenclatura"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["nombre_cuenta"] = $rTMP["nombre_cuenta"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["tiene_hijos"] = $rTMP["tiene_hijos"];
        
            $arrInfo["cuenta_contable"][$rTMP["id"]]["partida"][$rTMP["partida_id"]]["id"] = $rTMP["id"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["partida"][$rTMP["partida_id"]]["partida_id"] = $rTMP["partida_id"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["partida"][$rTMP["partida_id"]]["nomenclatura"] = $rTMP["nomenclatura"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["partida"][$rTMP["partida_id"]]["nombre_cuenta"] = $rTMP["nombre_cuenta"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["partida"][$rTMP["partida_id"]]["fecha"] = $rTMP["fecha"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["partida"][$rTMP["partida_id"]]["tipo_documento"] = $rTMP["tipo_documento"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["partida"][$rTMP["partida_id"]]["nombre_partida"] = $rTMP["nombre_partida"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["partida"][$rTMP["partida_id"]]["tipo_poliza"] = $rTMP["tipo_poliza"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["partida"][$rTMP["partida_id"]]["descripcion_partida"] = $rTMP["descripcion_partida"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["partida"][$rTMP["partida_id"]]["transaccion"] = $rTMP["transaccion"];
            $arrInfo["cuenta_contable"][$rTMP["id"]]["partida"][$rTMP["partida_id"]]["debe_recibe"] = $rTMP["debe_recibe"];  
            $arrInfo["cuenta_contable"][$rTMP["id"]]["partida"][$rTMP["partida_id"]]["haber_entrega"] = $rTMP["haber_entrega"];
            
        }
        db_free_result($qTMP);
        
        return $arrInfo;
    }
    
    public function getTransaccion($strFechaInicio, $strFechaFin){
        
        $strFechaInicio = !empty($strFechaInicio) ? $strFechaInicio : "";
        $arrFechaInicio = explode("/",$strFechaInicio);
        $strFechaInicio = $arrFechaInicio[2]."-".$arrFechaInicio[1]."-".$arrFechaInicio[0];
        
        $strFechaFin = !empty($strFechaFin) ? $strFechaFin : "";
        $arrFechaFin = explode("/",$strFechaFin);
        $strFechaFin = $arrFechaFin[2]."-".$arrFechaFin[1]."-".$arrFechaFin[0];     
              
        $arrTransacciones = array();
        $strQuery = "SELECT partida_transaccion.cuenta_contable,
                            partida.descripcion, partida.fecha, partida.partida,
                            partida_transaccion.transaccion,
                            partida_transaccion.tipo, partida_transaccion.monto
                     FROM   partida_transaccion, partida
                     WHERE  partida.fecha >= '{$strFechaInicio} 00:00:00'
                     AND    partida.fecha <= '{$strFechaFin} 23:59:59'
                     AND    partida_transaccion.partida = partida.partida
                     ORDER  BY partida_transaccion.cuenta_contable, partida.fecha, partida.partida";
                     
        
        $qTMP = db_query($strQuery);
        while( $rTMP = db_fetch_assoc($qTMP) ) {
            $arrTransacciones[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["partida"] = $rTMP["partida"];
            $arrTransacciones[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["fecha"] = $rTMP["fecha"];
            $arrTransacciones[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["descripcion"] = $rTMP["descripcion"];
            $arrTransacciones[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["monto"] = $rTMP["monto"];
            $arrTransacciones[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["tipo"] = $rTMP["tipo"];
        }
        db_free_result($qTMP);
        
        return $arrTransacciones;
    }
    
    public function getNoDocumento($strFechaInicio, $strFechaFin){
        
        $strFechaInicio = !empty($strFechaInicio) ? $strFechaInicio : "";
        $arrFechaInicio = explode("/",$strFechaInicio);
        $strFechaInicio = $arrFechaInicio[2]."-".$arrFechaInicio[1]."-".$arrFechaInicio[0];
        
        $strFechaFin = !empty($strFechaFin) ? $strFechaFin : "";
        $arrFechaFin = explode("/",$strFechaFin);
        $strFechaFin = $arrFechaFin[2]."-".$arrFechaFin[1]."-".$arrFechaFin[0]; 
        
        $arrDocumentos = array();
        $strQuery = "SELECT nota.nota, nota.partida, 
                            partida_transaccion.transaccion, 
                            partida_transaccion.cuenta_contable, 
                            nota.transaccion notaTransaccion,
                            nota.is_deposito,
                            nota.tipo
                     FROM   nota, 
                            partida_transaccion, 
                            partida 
                     WHERE  partida.fecha >= '{$strFechaInicio} 00:00:00'
                     AND    partida.fecha <= '{$strFechaFin} 23:59:59'
                     AND    nota.partida = partida.partida
                     AND    partida.partida = partida_transaccion.partida
                     ORDER  BY partida_transaccion.cuenta_contable, partida.partida";
        //debugQuery($strQuery);
        $qTMP = db_query($strQuery);
        while( $rTMP = db_fetch_assoc($qTMP) ) {
            
            $arrDocumentos[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["documento"] = $rTMP["is_deposito"] == 'Y' ? "DE {$rTMP["notaTransaccion"]}" : ($rTMP["tipo"] == "c" ? "NC {$rTMP["notaTransaccion"]}" : ( $rTMP["tipo"] == "d" ? "ND {$rTMP["notaTransaccion"]}" : "" ) );
            $arrDocumentos[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["tipo_poliza"] = $rTMP["is_deposito"] == 'Y' ? "Ingresos" : ($rTMP["tipo"] == "c" ? "Ajustes" : ( $rTMP["tipo"] == "d" ? "Egresos" : "" ));
            
        }
        db_free_result($qTMP);
        
        return $arrDocumentos;    
    } 
    
    public function getNoCheque( $strFechaInicio, $strFechaFin ){
        
        $strFechaInicio = !empty($strFechaInicio) ? $strFechaInicio : "";
        $arrFechaInicio = explode("/",$strFechaInicio);
        $strFechaInicio = $arrFechaInicio[2]."-".$arrFechaInicio[1]."-".$arrFechaInicio[0];
        
        $strFechaFin = !empty($strFechaFin) ? $strFechaFin : "";
        $arrFechaFin = explode("/",$strFechaFin);
        $strFechaFin = $arrFechaFin[2]."-".$arrFechaFin[1]."-".$arrFechaFin[0]; 
        
        $arrCheque = array();
        $strQuery = "SELECT cheque.cheque,
                            cheque.numerocheque,
                            partida_transaccion.cuenta_contable,
                            partida_transaccion.transaccion
                     FROM   cheque,
                            solicitud_cheque,
                            partida,
                            partida_transaccion
                     WHERE  partida.fecha >= '{$strFechaInicio} 00:00:00'
                     AND    partida.fecha <= '{$strFechaFin} 23:59:59'
                     AND    solicitud_cheque.partida = partida.partida
                     AND    partida_transaccion.cuenta_contable = solicitud_cheque.cuenta_contable
                     AND    partida_transaccion.partida = partida.partida";
        $qTMP = db_query($strQuery);
       // debugQuery($strQuery);    
        while($rTMP = db_fetch_assoc($qTMP)  ){
            $arrCheque[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["cheque"]  = "CH {$rTMP["numerocheque"]}";
            $arrCheque[$rTMP["cuenta_contable"]][$rTMP["transaccion"]]["tipo_poliza"]  = "Egresos";
        }
        
        return $arrCheque;
    } 
    
    public function getMonedaPrincipal(){
        
        $strSimboloMonedaPrincipal = sqlGetValueFromKey("SELECT moneda FROM moneda WHERE principal = 'Y'");
        $strSimbolo = !empty($strSimboloMonedaPrincipal) ? $strSimboloMonedaPrincipal : "";
        
        return $strSimbolo;
    }
    
    public function getCuentaBancaria($strCuentaBancaria = ""){
        
        $strCuentaBancaria = !empty($strCuentaBancaria) ? $strCuentaBancaria : "";
        $intCuentaBancaria = 0;
        
        if( !empty($strCuentaBancaria) ){
            
            $strQuery = "SELECT cuenta
                         FROM   cuenta
                         WHERE  MD5(cuenta) = '{$strCuentaBancaria}'";
            $intCuentaBancaria = sqlGetValueFromKey($strQuery);
            $intCuentaBancaria = intval($intCuentaBancaria);
        }
        
        return $intCuentaBancaria;
        
    }
    
}