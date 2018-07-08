import Foundation
import Eureka

class SortOrder: FormViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        func tableSortRow(forReadState readState: BookReadState, _ tableSort: TableSortOrder) -> ListCheckRow<TableSortOrder> {
            return ListCheckRow<TableSortOrder> {
                $0.title = tableSort.displayName
                $0.selectableValue = tableSort
                $0.onChange {
                    guard let selectedValue = $0.value else { return }
                    switch readState {
                    case .toRead: UserSettings.toReadSortOrder.value = selectedValue
                    case .reading: UserSettings.readingSortOrder.value = selectedValue
                    case .finished: UserSettings.finishedSortOrder.value = selectedValue
                    }
                    NotificationCenter.default.post(name: NSNotification.Name.BookSortOrderChanged, object: nil)
                    UserEngagement.logEvent(.changeSortOrder)
                    UserEngagement.onReviewTrigger()
                }
                $0.value = UserSettings.tableSortOrders[readState] == tableSort ? tableSort : nil
            }
        }

        // An empty section is used to add some explanation text at the top of the table
        form +++ Section(footer: """
            Set the order to be used when displaying books in each of the three sections: \
            To Read, Reading and Finished.
            """)

        +++ SelectableSection<ListCheckRow<TableSortOrder>>(header: "To Read", footer: """
                Title sorts the books alphabetically; Author sorts the books alphabetically by \
                the first author's surname; Custom allows the books to be sorted manually: tap \
                Edit and drag to reorder the books.
                """, selectionType: .singleSelection(enableDeselection: false))
            <<< tableSortRow(forReadState: .toRead, .customOrder)
            <<< tableSortRow(forReadState: .toRead, .byTitle)
            <<< tableSortRow(forReadState: .toRead, .byAuthor)

        +++ SelectableSection<ListCheckRow<TableSortOrder>>(header: "Reading", footer: """
                Start Date orders the books with the most recently started book first.
                """, selectionType: .singleSelection(enableDeselection: false))
            <<< tableSortRow(forReadState: .reading, .byStartDate)
            <<< tableSortRow(forReadState: .reading, .byTitle)
            <<< tableSortRow(forReadState: .reading, .byAuthor)

        +++ SelectableSection<ListCheckRow<TableSortOrder>>(header: "Finished", footer: """
                Finish Date orders the books with the most recently finished book first.
                """, selectionType: .singleSelection(enableDeselection: false))
            <<< tableSortRow(forReadState: .finished, .byStartDate)
            <<< tableSortRow(forReadState: .finished, .byFinishDate)
            <<< tableSortRow(forReadState: .finished, .byTitle)
            <<< tableSortRow(forReadState: .finished, .byAuthor)

        monitorThemeSetting()
    }
}
