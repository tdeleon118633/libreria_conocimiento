L0mel!nD3l.F413




$arrConfigSite = array();

$arrConfigSite["config"]["infomail"] = "asanchez@homeland.com.gt";

$arrConfigSite["config"]["local"] = true;

$arrConfigSite["db"]["database_resource"] = false;

$arrConfigSite["db"]["database_conexion"] = false;

$arrConfigSite["db"]["host"] = "localhost";

$arrConfigSite["db"]["database"] = "uspgtest_db";

$arrConfigSite["db"]["user"] = "uspgtest_usr";

$arrConfigSite["db"]["password"] = "A;ewn)kQPNau";

$arrConfigSite["moneda"]["tipo_cambio"] = "7.39";

se modifico el controller en getExcel
Se modifico en view en la funcion Descargar Excel


-- PROYECTO USPG

-- Excel
-- cuenta corriente / confirmacion de caja (uspgBeta hay data);

-- Fecha y hora (Rubro esta en la tabla transaccion)



-- primer por una fila por cada dorma de pago(rubro separado por coma)

-- segundo separado por rubro

-- El cambio se va a ser solo sobre el boton excel

--
forma de pago
transacciones ABONO
cuenta_corriente_recibo
cuenta_corriente_recibo_forma_pago (BANCO Y NUMERO CHEQUE)
Ordenado por fecha y Y NUMERO Recibo DE DOC FORMA DE PAGO

RUBRO

5,000
2,000
-------7,000
http://uspgtest.homelandplanet.com/cuenta_corriente_confirmacion_caja.php?strTipoDescarga=pdf

