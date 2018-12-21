CREATE OR REPLACE PACKAGE apexanalytics_plg_pkg IS
  --
  -- Plug-in Render Function
  -- #param p_dynamic_action
  -- #param p_plugin
  -- #return apex_plugin.t_dynamic_action_render_result
  FUNCTION render_apexanalytics(p_dynamic_action IN apex_plugin.t_dynamic_action,
                                p_plugin         IN apex_plugin.t_plugin)
    RETURN apex_plugin.t_dynamic_action_render_result;
  --
END apexanalytics_plg_pkg;
/
