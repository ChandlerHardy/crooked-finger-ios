//
//  ProjectDetailView.swift
//  Crooked Finger iOS
//
//  Created by Chandler Hardy on 10/3/25.
//

import SwiftUI

struct ProjectDetailView: View {
    let project: Project
    let viewModel: ProjectViewModel
    @State private var isFavorite: Bool
    @State private var status: ProjectStatus

    init(project: Project, viewModel: ProjectViewModel) {
        self.project = project
        self.viewModel = viewModel
        self._isFavorite = State(initialValue: project.isFavorite)
        self._status = State(initialValue: project.status)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(project.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appText)

                        Text(project.description)
                            .font(.subheadline)
                            .foregroundStyle(Color.appMuted)
                    }

                    Spacer()

                    Button {
                        isFavorite.toggle()
                    } label: {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundStyle(.yellow)
                            .font(.title2)
                    }
                }

                // Status Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Status")
                        .font(.headline)

                    Picker("Status", selection: $status) {
                        ForEach(ProjectStatus.allCases, id: \.self) { status in
                            Text(status.rawValue.capitalized).tag(status)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: status) { oldValue, newValue in
                        // Update backend when status changes
                        Task {
                            if let backendId = project.backendId {
                                await viewModel.updateProject(
                                    projectId: backendId,
                                    isCompleted: newValue == .completed
                                )
                            }
                        }
                    }
                }

                // Pattern
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pattern")
                        .font(.headline)

                    Text(project.pattern)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                // Notes
                VStack(alignment: .leading, spacing: 8) {
                    Text("Notes")
                        .font(.headline)

                    if let notes = project.notes {
                        Text(notes)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Text("No notes yet")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationTitle("Project Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ProjectDetailView(project: Project.mockProjects[0], viewModel: ProjectViewModel())
    }
}
