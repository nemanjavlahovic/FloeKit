import SwiftUI

public struct FloeDatePicker: View {
    @Binding var selectedDate: Date
    @State private var displayedMonth: Date
    @State private var selectedTime: Date
    @State private var showingTimePicker: Bool = false
    
    public enum Style {
        case calendar
        case inline
        case compact
        case wheel
    }
    
    public enum SelectionMode {
        case date
        case time
        case dateAndTime
    }
    
    private let style: Style
    private let selectionMode: SelectionMode
    private let minDate: Date?
    private let maxDate: Date?
    private let highlightedDates: Set<Date>
    private let disabledDates: Set<Date>
    private let accentColor: Color
    private let showWeekNumbers: Bool
    private let firstDayOfWeek: Int
    private let onChange: ((Date) -> Void)?
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    public init(
        selectedDate: Binding<Date>,
        style: Style = .calendar,
        selectionMode: SelectionMode = .date,
        minDate: Date? = nil,
        maxDate: Date? = nil,
        highlightedDates: Set<Date> = [],
        disabledDates: Set<Date> = [],
        accentColor: Color = FloeColors.primary,
        showWeekNumbers: Bool = false,
        firstDayOfWeek: Int = 1,
        onChange: ((Date) -> Void)? = nil
    ) {
        self._selectedDate = selectedDate
        self.style = style
        self.selectionMode = selectionMode
        self.minDate = minDate
        self.maxDate = maxDate
        self.highlightedDates = highlightedDates
        self.disabledDates = disabledDates
        self.accentColor = accentColor
        self.showWeekNumbers = showWeekNumbers
        self.firstDayOfWeek = firstDayOfWeek
        self.onChange = onChange
        self._displayedMonth = State(initialValue: selectedDate.wrappedValue)
        self._selectedTime = State(initialValue: selectedDate.wrappedValue)
    }
    
    public var body: some View {
        switch style {
        case .calendar:
            calendarView
        case .inline:
            inlineView
        case .compact:
            compactView
        case .wheel:
            wheelView
        }
    }
    
    // MARK: - Calendar Style
    
    private var calendarView: some View {
        VStack(spacing: 16) {
            // Month navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(accentColor)
                }
                
                Spacer()
                
                Text(dateFormatter.string(from: displayedMonth))
                    .font(.headline)
                    .foregroundColor(FloeColors.neutral10)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(accentColor)
                }
            }
            .padding(.horizontal)
            
            // Weekday headers
            HStack(spacing: 0) {
                if showWeekNumbers {
                    Text("W")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(FloeColors.neutral40)
                        .frame(width: 30)
                }
                
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(FloeColors.neutral40)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            
            // Calendar grid
            LazyVGrid(columns: gridColumns, spacing: 8) {
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        DayCell(
                            date: date,
                            isSelected: isSameDay(date, selectedDate),
                            isToday: isSameDay(date, Date()),
                            isHighlighted: highlightedDates.contains { isSameDay($0, date) },
                            isDisabled: isDateDisabled(date),
                            isInCurrentMonth: isSameMonth(date, displayedMonth),
                            accentColor: accentColor
                        ) {
                            selectDate(date)
                        }
                    } else {
                        Color.clear
                            .frame(height: 36)
                    }
                }
            }
            .padding(.horizontal)
            
            if selectionMode == .dateAndTime {
                Divider()
                
                HStack {
                    Text("Time")
                        .font(.subheadline)
                        .foregroundColor(FloeColors.neutral40)
                    
                    Spacer()
                    
                    Button(action: { showingTimePicker.toggle() }) {
                        Text(timeFormatter.string(from: selectedTime))
                            .font(.system(.body, design: .rounded))
                            .foregroundColor(accentColor)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(FloeColors.surface)
        )
        .sheet(isPresented: $showingTimePicker) {
            TimePickerSheet(selectedTime: $selectedTime) { time in
                updateDateTime(with: time)
            }
        }
    }
    
    // MARK: - Inline Style
    
    private var inlineView: some View {
        DatePicker(
            "",
            selection: $selectedDate,
            in: dateRange,
            displayedComponents: displayedComponents
        )
        .datePickerStyle(.graphical)
        .accentColor(accentColor)
        .onChange(of: selectedDate) { newValue in
            onChange?(newValue)
        }
    }
    
    // MARK: - Compact Style
    
    private var compactView: some View {
        DatePicker(
            "",
            selection: $selectedDate,
            in: dateRange,
            displayedComponents: displayedComponents
        )
        .datePickerStyle(.compact)
        .accentColor(accentColor)
        .onChange(of: selectedDate) { newValue in
            onChange?(newValue)
        }
    }
    
    // MARK: - Wheel Style
    
    private var wheelView: some View {
        #if os(iOS)
        DatePicker(
            "",
            selection: $selectedDate,
            in: dateRange,
            displayedComponents: displayedComponents
        )
        .datePickerStyle(.wheel)
        .accentColor(accentColor)
        .onChange(of: selectedDate) { newValue in
            onChange?(newValue)
        }
        #else
        inlineView
        #endif
    }
    
    // MARK: - Helper Properties
    
    private var dateRange: ClosedRange<Date> {
        let min = minDate ?? Date.distantPast
        let max = maxDate ?? Date.distantFuture
        return min...max
    }
    
    private var displayedComponents: DatePickerComponents {
        switch selectionMode {
        case .date:
            return .date
        case .time:
            return .hourAndMinute
        case .dateAndTime:
            return [.date, .hourAndMinute]
        }
    }
    
    private var weekdaySymbols: [String] {
        let symbols = calendar.veryShortWeekdaySymbols
        return Array(symbols[firstDayOfWeek..<symbols.count] + symbols[0..<firstDayOfWeek])
    }
    
    private var gridColumns: [GridItem] {
        var columns: [GridItem] = []
        if showWeekNumbers {
            columns.append(GridItem(.fixed(30)))
        }
        columns.append(contentsOf: Array(repeating: GridItem(.flexible()), count: 7))
        return columns
    }
    
    private var calendarDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let firstWeekday = calendar.dateComponents([.weekday], from: monthInterval.start).weekday else {
            return []
        }
        
        let adjustedFirstWeekday = (firstWeekday - firstDayOfWeek + 7) % 7
        let leadingEmptyDays = adjustedFirstWeekday == 0 ? 0 : adjustedFirstWeekday
        
        var days: [Date?] = Array(repeating: nil, count: leadingEmptyDays)
        
        let numberOfDaysInMonth = calendar.range(of: .day, in: .month, for: displayedMonth)?.count ?? 0
        for day in 1...numberOfDaysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthInterval.start) {
                days.append(date)
            }
        }
        
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
    
    // MARK: - Helper Methods
    
    private func previousMonth() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
        }
    }
    
    private func selectDate(_ date: Date) {
        guard !isDateDisabled(date) else { return }
        
        if selectionMode == .dateAndTime {
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)
            
            var newComponents = DateComponents()
            newComponents.year = components.year
            newComponents.month = components.month
            newComponents.day = components.day
            newComponents.hour = timeComponents.hour
            newComponents.minute = timeComponents.minute
            
            if let newDate = calendar.date(from: newComponents) {
                selectedDate = newDate
                onChange?(newDate)
            }
        } else {
            selectedDate = date
            onChange?(date)
        }
        
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
    }
    
    private func updateDateTime(with time: Date) {
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var newComponents = DateComponents()
        newComponents.year = dateComponents.year
        newComponents.month = dateComponents.month
        newComponents.day = dateComponents.day
        newComponents.hour = timeComponents.hour
        newComponents.minute = timeComponents.minute
        
        if let newDate = calendar.date(from: newComponents) {
            selectedDate = newDate
            selectedTime = time
            onChange?(newDate)
        }
    }
    
    private func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, inSameDayAs: date2)
    }
    
    private func isSameMonth(_ date1: Date, _ date2: Date) -> Bool {
        calendar.isDate(date1, equalTo: date2, toGranularity: .month)
    }
    
    private func isDateDisabled(_ date: Date) -> Bool {
        if let minDate = minDate, date < minDate {
            return true
        }
        if let maxDate = maxDate, date > maxDate {
            return true
        }
        return disabledDates.contains { isSameDay($0, date) }
    }
}

// MARK: - Day Cell

private struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isHighlighted: Bool
    let isDisabled: Bool
    let isInCurrentMonth: Bool
    let accentColor: Color
    let action: () -> Void
    
    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter
    }()
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isSelected {
                    Circle()
                        .fill(accentColor)
                        .frame(width: 36, height: 36)
                } else if isToday {
                    Circle()
                        .stroke(accentColor, lineWidth: 2)
                        .frame(width: 36, height: 36)
                }
                
                if isHighlighted && !isSelected {
                    Circle()
                        .fill(accentColor.opacity(0.2))
                        .frame(width: 30, height: 30)
                }
                
                Text(dayFormatter.string(from: date))
                    .font(.system(size: 14, weight: isToday ? .semibold : .regular))
                    .foregroundColor(textColor)
            }
            .frame(width: 36, height: 36)
        }
        .disabled(isDisabled)
    }
    
    private var textColor: Color {
        if isDisabled {
            return FloeColors.neutral30
        } else if isSelected {
            return .white
        } else if !isInCurrentMonth {
            return FloeColors.neutral40
        } else {
            return FloeColors.neutral10
        }
    }
}

// MARK: - Time Picker Sheet

private struct TimePickerSheet: View {
    @Binding var selectedTime: Date
    @Environment(\.dismiss) private var dismiss
    let onSelect: (Date) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Time",
                    selection: $selectedTime,
                    displayedComponents: .hourAndMinute
                )
                #if os(iOS)
                .datePickerStyle(.wheel)
                #else
                .datePickerStyle(.compact)
                #endif
                .labelsHidden()
                
                Spacer()
            }
            .padding()
            .navigationTitle("Select Time")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onSelect(selectedTime)
                        dismiss()
                    }
                    .font(.body.bold())
                }
            }
        }
    }
}

// MARK: - Convenience Initializers

public extension FloeDatePicker {
    static func calendar(
        selectedDate: Binding<Date>,
        minDate: Date? = nil,
        maxDate: Date? = nil,
        onChange: ((Date) -> Void)? = nil
    ) -> FloeDatePicker {
        FloeDatePicker(
            selectedDate: selectedDate,
            style: .calendar,
            minDate: minDate,
            maxDate: maxDate,
            onChange: onChange
        )
    }
    
    static func inline(
        selectedDate: Binding<Date>,
        selectionMode: SelectionMode = .date,
        onChange: ((Date) -> Void)? = nil
    ) -> FloeDatePicker {
        FloeDatePicker(
            selectedDate: selectedDate,
            style: .inline,
            selectionMode: selectionMode,
            onChange: onChange
        )
    }
    
    static func compact(
        selectedDate: Binding<Date>,
        selectionMode: SelectionMode = .date,
        onChange: ((Date) -> Void)? = nil
    ) -> FloeDatePicker {
        FloeDatePicker(
            selectedDate: selectedDate,
            style: .compact,
            selectionMode: selectionMode,
            onChange: onChange
        )
    }
}

// MARK: - Previews

struct FloeDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        DatePickerPreviewView()
    }
    
    struct DatePickerPreviewView: View {
        @State private var date1 = Date()
        @State private var date2 = Date()
        @State private var date3 = Date()
        @State private var date4 = Date()
        
        var body: some View {
            ScrollView {
                VStack(spacing: 32) {
                    Text("FloeDatePicker Examples")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Calendar Style")
                            .font(.headline)
                        
                        FloeDatePicker.calendar(
                            selectedDate: $date1,
                            minDate: Date(),
                            onChange: { date in
                                print("Selected: \(date)")
                            }
                        )
                        
                        Text("Selected: \(date1.formatted())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Calendar with Time")
                            .font(.headline)
                        
                        FloeDatePicker(
                            selectedDate: $date2,
                            style: .calendar,
                            selectionMode: .dateAndTime,
                            highlightedDates: [
                                Date().addingTimeInterval(86400),
                                Date().addingTimeInterval(86400 * 3)
                            ]
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Inline Style")
                            .font(.headline)
                        
                        FloeDatePicker.inline(
                            selectedDate: $date3,
                            selectionMode: .date
                        )
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Compact Style")
                            .font(.headline)
                        
                        HStack {
                            Text("Date:")
                            FloeDatePicker.compact(
                                selectedDate: $date4,
                                selectionMode: .dateAndTime
                            )
                            Spacer()
                        }
                    }
                }
                .padding()
            }
        }
    }
}