[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Orders_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Orders = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "4031375f-1d22-4362-ab6f-14d47907152e"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "8a1ee3dd-0d70-43df-b9ba-c723d289fdf5"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "day6_source"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "retail_orders.csv"]}[Content],
  #"Imported CSV" = Csv.Document(#"Navigation 4", [Delimiter = ",", Columns = 11, Encoding = 65001, QuoteStyle = QuoteStyle.None]),
  #"Changed column type" = Table.TransformColumnTypes(#"Imported CSV", {{"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type text}, {"Column7", type text}, {"Column8", type text}, {"Column9", type text}, {"Column10", type text}, {"Column11", type text}}),
  #"Promoted headers" = Table.PromoteHeaders(#"Changed column type", [PromoteAllScalars = true]),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Promoted headers", {{"order_date", type date}, {"quantity", type text}, {"unit_price_usd", type number}}, "en"),
  #"Trimmed text" = Table.TransformColumns(#"Changed column type 1", {{"quantity", each Text.Trim(_), type nullable text}}),
  #"Changed column type 2" = Table.TransformColumnTypes(#"Trimmed text", {{"quantity", Int64.Type}}),
  #"Capitalized each word" = Table.TransformColumns(#"Changed column type 2", {{"sales_channel", each Text.Proper(_), type nullable text}}),
  #"Replaced value" = Table.ReplaceValue(#"Capitalized each word", null, "Unknown", Replacer.ReplaceValue, {"region"}),
  #"Replaced value 1" = Table.ReplaceValue(#"Replaced value", "", "Unknown", Replacer.ReplaceValue, {"region"}),
  #"Removed duplicates" = Table.Distinct(#"Replaced value 1", {"order_id", "order_date", "customer_name", "region", "country", "product_id", "quantity", "unit_price_usd", "sales_channel", "payment_method", "order_status"}),
  #"Added custom" = Table.AddColumn(#"Removed duplicates", "line_total_usd", each [quantity] * [unit_price_usd]),
  #"Inserted conditional column" = Table.AddColumn(#"Added custom", "order_size", each if [quantity] = 1 then """Single Item""" else if [quantity] <= 3 then """Small Order""" else """Bulk Order"""),
  #"Changed column type 3" = Table.TransformColumnTypes(#"Inserted conditional column", {{"line_total_usd", type number}}),
  #"Merged queries" = Table.NestedJoin(#"Changed column type 3", {"product_id"}, Products, {"product_id"}, "Products", JoinKind.LeftOuter),
  #"Expanded Products" = Table.ExpandTableColumn(#"Merged queries", "Products", {"product_name", "category", "unit_cost_usd"}, {"product_name", "category", "unit_cost_usd"}),
  #"Added custom 1" = Table.AddColumn(#"Expanded Products", "profit_usd", each [line_total_usd] - ([quantity] * [unit_cost_usd]))
in
  #"Added custom 1";
shared Products = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "4031375f-1d22-4362-ab6f-14d47907152e"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "8a1ee3dd-0d70-43df-b9ba-c723d289fdf5"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "day6_source"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "product_lookup.csv"]}[Content],
  #"Imported CSV" = Csv.Document(#"Navigation 4", [Delimiter = ",", Columns = 4, QuoteStyle = QuoteStyle.None]),
  #"Promoted headers" = Table.PromoteHeaders(#"Imported CSV", [PromoteAllScalars = true]),
  #"Changed column type" = Table.TransformColumnTypes(#"Promoted headers", {{"product_id", type text}, {"product_name", type text}, {"category", type text}, {"unit_cost_usd", type number}}, "en")
in
  #"Changed column type";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Orders_completed_only_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Orders_completed_only = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "4031375f-1d22-4362-ab6f-14d47907152e"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "8a1ee3dd-0d70-43df-b9ba-c723d289fdf5"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "day6_source"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "retail_orders.csv"]}[Content],
  #"Imported CSV" = Csv.Document(#"Navigation 4", [Delimiter = ",", Columns = 11, Encoding = 65001, QuoteStyle = QuoteStyle.None]),
  #"Changed column type" = Table.TransformColumnTypes(#"Imported CSV", {{"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type text}, {"Column7", type text}, {"Column8", type text}, {"Column9", type text}, {"Column10", type text}, {"Column11", type text}}),
  #"Promoted headers" = Table.PromoteHeaders(#"Changed column type", [PromoteAllScalars = true]),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Promoted headers", {{"order_date", type date}, {"quantity", type text}, {"unit_price_usd", type number}}, "en"),
  #"Trimmed text" = Table.TransformColumns(#"Changed column type 1", {{"quantity", each Text.Trim(_), type nullable text}}),
  #"Changed column type 2" = Table.TransformColumnTypes(#"Trimmed text", {{"quantity", Int64.Type}}),
  #"Capitalized each word" = Table.TransformColumns(#"Changed column type 2", {{"sales_channel", each Text.Proper(_), type nullable text}}),
  #"Replaced value" = Table.ReplaceValue(#"Capitalized each word", null, "Unknown", Replacer.ReplaceValue, {"region"}),
  #"Replaced value 1" = Table.ReplaceValue(#"Replaced value", "", "Unknown", Replacer.ReplaceValue, {"region"}),
  #"Removed duplicates" = Table.Distinct(#"Replaced value 1", {"order_id", "order_date", "customer_name", "region", "country", "product_id", "quantity", "unit_price_usd", "sales_channel", "payment_method", "order_status"}),
  #"Added custom" = Table.AddColumn(#"Removed duplicates", "line_total_usd", each [quantity] * [unit_price_usd]),
  #"Inserted conditional column" = Table.AddColumn(#"Added custom", "order_size", each if [quantity] = 1 then """Single Item""" else if [quantity] <= 3 then """Small Order""" else """Bulk Order"""),
  #"Changed column type 3" = Table.TransformColumnTypes(#"Inserted conditional column", {{"line_total_usd", type number}}),
  #"Merged queries" = Table.NestedJoin(#"Changed column type 3", {"product_id"}, Products, {"product_id"}, "Products", JoinKind.LeftOuter),
  #"Expanded Products" = Table.ExpandTableColumn(#"Merged queries", "Products", {"product_name", "category", "unit_cost_usd"}, {"product_name", "category", "unit_cost_usd"}),
  #"Added custom 1" = Table.AddColumn(#"Expanded Products", "profit_usd", each [line_total_usd] - ([quantity] * [unit_cost_usd])),
  #"Filtered rows" = Table.SelectRows(#"Added custom 1", each ([order_status] = "Completed"))
in
  #"Filtered rows";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Category_summary_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Category_summary = let
  Source = Lakehouse.Contents(null),
  Navigation = Source{[workspaceId = "4031375f-1d22-4362-ab6f-14d47907152e"]}[Data],
  #"Navigation 1" = Navigation{[lakehouseId = "8a1ee3dd-0d70-43df-b9ba-c723d289fdf5"]}[Data],
  #"Navigation 2" = #"Navigation 1"{[Id = "Files", ItemKind = "Folder"]}[Data],
  #"Navigation 3" = #"Navigation 2"{[Name = "day6_source"]}[Content],
  #"Navigation 4" = #"Navigation 3"{[Name = "retail_orders.csv"]}[Content],
  #"Imported CSV" = Csv.Document(#"Navigation 4", [Delimiter = ",", Columns = 11, Encoding = 65001, QuoteStyle = QuoteStyle.None]),
  #"Changed column type" = Table.TransformColumnTypes(#"Imported CSV", {{"Column1", type text}, {"Column2", type text}, {"Column3", type text}, {"Column4", type text}, {"Column5", type text}, {"Column6", type text}, {"Column7", type text}, {"Column8", type text}, {"Column9", type text}, {"Column10", type text}, {"Column11", type text}}),
  #"Promoted headers" = Table.PromoteHeaders(#"Changed column type", [PromoteAllScalars = true]),
  #"Changed column type 1" = Table.TransformColumnTypes(#"Promoted headers", {{"order_date", type date}, {"quantity", type text}, {"unit_price_usd", type number}}, "en"),
  #"Trimmed text" = Table.TransformColumns(#"Changed column type 1", {{"quantity", each Text.Trim(_), type nullable text}}),
  #"Changed column type 2" = Table.TransformColumnTypes(#"Trimmed text", {{"quantity", Int64.Type}}),
  #"Capitalized each word" = Table.TransformColumns(#"Changed column type 2", {{"sales_channel", each Text.Proper(_), type nullable text}}),
  #"Replaced value" = Table.ReplaceValue(#"Capitalized each word", null, "Unknown", Replacer.ReplaceValue, {"region"}),
  #"Replaced value 1" = Table.ReplaceValue(#"Replaced value", "", "Unknown", Replacer.ReplaceValue, {"region"}),
  #"Removed duplicates" = Table.Distinct(#"Replaced value 1", {"order_id", "order_date", "customer_name", "region", "country", "product_id", "quantity", "unit_price_usd", "sales_channel", "payment_method", "order_status"}),
  #"Added custom" = Table.AddColumn(#"Removed duplicates", "line_total_usd", each [quantity] * [unit_price_usd]),
  #"Inserted conditional column" = Table.AddColumn(#"Added custom", "order_size", each if [quantity] = 1 then """Single Item""" else if [quantity] <= 3 then """Small Order""" else """Bulk Order"""),
  #"Changed column type 3" = Table.TransformColumnTypes(#"Inserted conditional column", {{"line_total_usd", type number}}),
  #"Merged queries" = Table.NestedJoin(#"Changed column type 3", {"product_id"}, Products, {"product_id"}, "Products", JoinKind.LeftOuter),
  #"Expanded Products" = Table.ExpandTableColumn(#"Merged queries", "Products", {"product_name", "category", "unit_cost_usd"}, {"product_name", "category", "unit_cost_usd"}),
  #"Added custom 1" = Table.AddColumn(#"Expanded Products", "profit_usd", each [line_total_usd] - ([quantity] * [unit_cost_usd])),
  #"Filtered rows" = Table.SelectRows(#"Added custom 1", each ([order_status] = "Completed")),
  #"Grouped rows" = Table.Group(#"Filtered rows", {"category"}, {{"total_revenue", each List.Sum([line_total_usd]), type nullable number}, {"total_profit", each List.Sum([profit_usd]), type any}, {"order_count", each Table.RowCount(_), Int64.Type}})
in
  #"Grouped rows";
shared Orders_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "4031375f-1d22-4362-ab6f-14d47907152e"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "8a1ee3dd-0d70-43df-b9ba-c723d289fdf5"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "orders_enriched", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Category_summary_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "4031375f-1d22-4362-ab6f-14d47907152e"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "8a1ee3dd-0d70-43df-b9ba-c723d289fdf5"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "Category_summary", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Orders_completed_only_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true]),
  Navigation_1 = Pattern{[workspaceId = "4031375f-1d22-4362-ab6f-14d47907152e"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "8a1ee3dd-0d70-43df-b9ba-c723d289fdf5"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "orders_completed_only", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
