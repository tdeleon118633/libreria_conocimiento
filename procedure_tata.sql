DELIMITER $$

CREATE  PROCEDURE SP_Cerrar_POs_test()

	BEGIN

	DECLARE Orden, Temporal CHAR (7);
	DECLARE Bandera BOOL DEFAULT FALSE;
	DECLARE Diferencia_Dias INT DEFAULT 0;
	DECLARE Recepcionado,Requerido DECIMAL (10,3);
	DECLARE done INT DEFAULT 0;
	DECLARE Cantidad INT DEFAULT 0;
	DECLARE proj_done, attribute_done BOOLEAN DEFAULT FALSE;  

	-- Trae las ordenes que se requiere Cerrar
	DECLARE cur CURSOR FOR  SELECT VC.POHdrNumber As PO, VC.RMIQty As Rec, VQ.PODetQty As Req, (datediff(VC.RMIReceptionDate,date(now()))*-1) As Dif
										FROM V_PO_Recep_Open VC, V_PO_Req_Open VQ WHERE VC.POHdrNumber = VQ.POHdrNumber AND VC.MatCode = VQ.MatCode GROUP BY PO;



	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' SET done = 1;

	OPEN cur;
	SET Temporal = '';

	REPEAT

	FETCH cur INTO Orden, Recepcionado, Requerido, Diferencia_Dias;
	IF NOT done THEN
		-- ##############################################################################################

		-- SELECT SUM(VQ.PODetQty ) 	 As Cantidad FROM V_PO_Recep_Open VC, V_PO_Req_Open VQ WHERE VC.POHdrNumber = VQ.POHdrNumber AND VC.MatCode = VQ.MatCode AND VC.POHdrNumber= Orden INTO @Cantidad;
		
		-- declaracion de segundo recorrido
		
		BLOCK1 : BEGIN
		DECLARE cur_rec_orden CURSOR FOR SELECT REC_VC.POHdrNumber As REC_PO, REC_VC.RMIQty As REC_Rec, REC_VQ.PODetQty As REC_Req, (datediff(REC_VC.RMIReceptionDate,date(now()))*-1) As REC_Dif
										  FROM V_PO_Recep_Open REC_VC, V_PO_Req_Open REC_VQ WHERE REC_VC.POHdrNumber = REC_VQ.POHdrNumber 
										  AND REC_VC.MatCode = REC_VQ.MatCode
										  AND   REC_VC.POHdrNumber = Orden;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET attribute_done = TRUE;
										  
		OPEN cur_rec_orden;
		loop2: LOOP
			FETCH  cur_rec_orden INTO REC_PO, REC_Rec, REC_Req, REC_Dif;
				
			INSERT INTO loop_test(rec,req) VALUE(REC_Rec,REC_Req);
			
			CLOSE loop2;
			LEAVE loop2;
		END LOOP loop2;		
		CLOSE cur_rec_orden;
		END BLOCK1;
		
			 -- INSERT INTO loop_test(rec,req) VALUE(Recepcionado,Requerido);
		
		-- ##############################################################################################
	END IF;

	UNTIL done END REPEAT;
	CLOSE cur;
END $$
DELIMITER ;