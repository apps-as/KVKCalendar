//
//  TimeLineView+Layout.swift
//  KVKCalendar
//
//  Created by Tamás Oszkó on 2020. 08. 05..
//

import Foundation
import UIKit

extension TimelineView {
    func createLayoutDescriptors(from events: [Event]) -> [EventLayoutDescriptor] {
        let layoutDescriptors = events.map { (event) -> EventLayoutDescriptor in
            var descriptor = EventLayoutDescriptor(
                event: event, intesectingEvents:
                events.others(than: event).intercetions(with: event))
            let maxIntersections = descriptor.intesectingEvents.maxIntersetionsByOverlappingGroups(with: descriptor.event)
            descriptor.widthPercetage = 1.0 / CGFloat(maxIntersections + 1)
            return descriptor
        }.sorted {
            $0.event.from < $1.event.from
        }
        return adjustedLayoutDescriptors(descriptors: layoutDescriptors)
    }

    private func adjustedLayoutDescriptors(descriptors: [EventLayoutDescriptor]) -> [EventLayoutDescriptor] {
        return descriptors.map { (descriptor) -> EventLayoutDescriptor in
            if descriptor.intesectingEvents.count > 0 {
                let intercetingDescriptors = descriptors.filteredBy(ids: descriptor.intesectingEvents.map { $0.ID })
                let usedWidth = intercetingDescriptors.reduce(descriptor.widthPercetage) { $0 + $1.widthPercetage }
                let availableWidth = max(0, 1 - usedWidth)
                let newWidth = descriptor.widthPercetage + availableWidth
                return EventLayoutDescriptor(event: descriptor.event, intesectingEvents: descriptor.intesectingEvents, widthPercetage: newWidth)
            }
            return descriptor
        }
    }
}

extension Event {

    private static let epsilon: TimeInterval = 10e-6

    var from: TimeInterval {
        self.start.timeIntervalSince1970
    }

    private var toAdjusted: TimeInterval {
        self.end.timeIntervalSince1970 - Event.epsilon
    }

    var duration: TimeInterval {
        self.end.timeIntervalSince(self.start)
    }

    func contains(timestamp: TimeInterval) -> Bool {
        return from...toAdjusted ~= timestamp
    }

    func intersects(_ other: Event) -> Bool {
        return other.contains(timestamp: from) ||
            other.contains(timestamp: toAdjusted) ||
            contains(timestamp: other.from) ||
            contains(timestamp: other.toAdjusted)
    }
}

 extension Array where Element == Event {

    func intercetions(with item: Element) -> [Element] {
        return self.filter { item.intersects($0) }
    }

    func maxIntersetionsByOverlappingGroups(with item: Element) -> Int {
        let groups = others(than: item).getOverlappingGroups()
        let max = groups.map { $0.maxIntersections(with: item) }.max() ?? 0
        return max
    }

    func maxIntersections(with item: Element) -> Int {
        let otherItems = others(than: item)
        let counts = otherItems.map { otherItems.intercetions(with: $0).count }
        let max = counts.max() ?? 0
        return max
    }

    func getOverlappingGroups() -> [[Element]] {
        var groups = [[Element]]()
        var allItems = self
        while !allItems.isEmpty {
            let item = allItems.remove(at: 0)
            let intercesting = allItems.intercetions(with: item)
            let line = [item] + intercesting
            groups.append(line)
            let removeIds = intercesting.map { $0.ID }
            allItems.removeAll {
                removeIds.contains($0.ID)
            }
        }
        return groups
    }

    func others(than: Element) -> [Element] {
        return self.filter { $0.ID != than.ID }
    }
}

private extension Array where Element == EventLayoutDescriptor {
    func filteredBy(ids: [String]) -> [Element] {
        return filter { ids.contains($0.id) }
    }
}
