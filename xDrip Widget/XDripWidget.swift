//
//  XDripWidget.swift
//  XDripWidget
//
//  Created by Paul Plant on 30/12/23.
//  Copyright © 2023 Johan Degraeve. All rights reserved.
//

import WidgetKit
import SwiftUI

struct XDripWidget: Widget {
    let kind: String = "xDripWidget"
    
    private var supportedFamilies: [WidgetFamily] {
        var families: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge]
        if #available(iOSApplicationExtension 16.0, *) {
            families.append(.accessoryCircular)
            families.append(.accessoryRectangular)
        }
        return families
    }
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            XDripWidget.EntryView(entry: entry)
                .widgetBackground(backgroundView: Color.black)
        }
        .configurationDisplayName(ConstantsHomeView.applicationName)
        .description("Show the current blood glucose level")
        .supportedFamilies(supportedFamilies)
    }
}

struct XDripWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            XDripWidget.EntryView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .previewDisplayName("systemSmall")
            XDripWidget.EntryView(entry: .placeholder)
                .previewContext(WidgetPreviewContext(family: .systemMedium))
                .previewDisplayName("systemMedium")
            if #available(iOSApplicationExtension 16.0, *) {
                XDripWidget.EntryView(entry: .placeholder)
                    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
                    .previewDisplayName("accessoryCircular")
                XDripWidget.EntryView(entry: .placeholder)
                    .previewContext(WidgetPreviewContext(family: .accessoryInline))
                    .previewDisplayName("accessoryInline")
            }
        }
    }
}
