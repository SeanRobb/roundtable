import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import AddOptionPopUp from './addOptionPopUp';

describe('<AddOptionPopUp />', () => {
  test('it should mount', () => {
    render(<AddOptionPopUp />);
    
    const addOptionPopUp = screen.getByTestId('AddOptionPopUp');

    expect(addOptionPopUp).toBeInTheDocument();
  });
});