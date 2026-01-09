*& Report ZEVO_MAINTENANCE_PLAN SCH REP

*& Author:
*& Username: MOOSHUBER
* & Project: Maintenance Plan Scheduler
*& Description:
*& Process Owner: Srinivasan
*& Creation: 30.01.2025

REPORT zevo_maintenance_plan_sch_rep.

"Includes
INCLUDE zevo_maintenance_plan_sch_top.
INCLUDE zevo maintenance plan sch form.

START-OF-SELECTION.

PERFORM get data.
PERFORM alv_output.


